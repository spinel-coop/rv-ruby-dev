# typed: strict

class Homebrew::Cmd::RvPackageCmd
  sig { returns(Homebrew::Cmd::PortablePackageCmd::Args) }
  def args; end
end

class Homebrew::Cmd::RvPackageCmd::Args < Homebrew::CLI::Args
  sig { returns(T::Boolean) }
  def no_uninstall_deps?; end
end
