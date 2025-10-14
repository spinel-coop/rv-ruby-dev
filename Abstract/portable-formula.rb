# frozen_string_literal: true

module PortableFormulaMixin
  if OS.mac?
    if Hardware::CPU.arm?
      TARGET_MACOS = :sonoma
      TARGET_DARWIN_VERSION = Version.new("23.6.0").freeze
    else
      TARGET_MACOS = :ventura
      TARGET_DARWIN_VERSION = Version.new("22.6.0").freeze
    end
  end

  def install
    if OS.mac?
      if OS::Mac.version > TARGET_MACOS
        target_macos_humanized = TARGET_MACOS.to_s.tr("_", " ").split.map(&:capitalize).join(" ")

        opoo <<~EOS
          You are building portable formula on #{OS::Mac.version}.
          As result, formula won't be able to work on older macOS versions.
          It's recommended to build this formula on macOS #{target_macos_humanized}
          (the oldest version that can run Homebrew).
        EOS
      end

      # Always prefer to linking to portable libs.
      ENV.append "LDFLAGS", "-Wl,-search_paths_first"
    elsif OS.linux?
      # reset Linuxbrew env, because we want to build formula against
      # libraries offered by system (CentOS docker) rather than Linuxbrew.
      ENV.delete "LDFLAGS"
      ENV.delete "LIBRARY_PATH"
      ENV.delete "LD_RUN_PATH"
      ENV.delete "LD_LIBRARY_PATH"
      ENV.delete "TERMINFO_DIRS"
      ENV.delete "HOMEBREW_RPATH_PATHS"
      ENV.delete "HOMEBREW_DYNAMIC_LINKER"

      # https://github.com/Homebrew/homebrew-portable-ruby/issues/118
      ENV.append_to_cflags "-fPIC"
    end

    super
  end

  def test
    refute_match(/Homebrew libraries/,
                 shell_output("#{HOMEBREW_BREW_FILE} linkage #{full_name}"))

    super
  end
end

class PortableFormula < Formula
  desc "Abstract portable formula"
  homepage "https://github.com/spinel-coop/rv-ruby"

  def self.inherited(subclass)
    subclass.class_eval do
      super

      keg_only "portable formulae are keg-only"

      on_linux do
        depends_on "glibc@2.17" => :build
        depends_on "linux-headers@4.4" => :build
      end

      prepend PortableFormulaMixin
    end
  end
end
