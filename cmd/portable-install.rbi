# typed: strict

class Homebrew::Cmd::PortableInstallCmd
  sig { returns(Homebrew::Cmd::PortableInstallCmd::Args) }
  def args; end
end

class Homebrew::Cmd::PortableInstallCmd::Args < Homebrew::CLI::Args
  sig { returns(T::Boolean) }
  def no_uninstall_deps?; end
end
