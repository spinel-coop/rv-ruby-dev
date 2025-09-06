# typed: strict
# frozen_string_literal: true

require "abstract_command"
require "development_tools"
require "dependency"

module Homebrew
  module Cmd
    class PortablePackageCmd < AbstractCommand
      cmd_args do
        usage_banner <<~EOS
          `portable-package` <formulae>

          Build and package portable formulae.
        EOS
        switch "--no-uninstall-deps",
               description: "Don't uninstall all dependencies of portable formulae before testing."
        switch "-v", "--verbose",
               description: "Pass `--verbose` to `brew` commands."
        named_args :formula, min: 1
      end

      sig { override.void }
      def run
        ENV["HOMEBREW_DEVELOPER"] = "1"

        verbose = []
        verbose << "--verbose" if args.verbose?
        verbose << "--debug" if args.debug?

        # If test-bot cleanup is performed and auto-updates are disabled, this might not already be installed.
        unless DevelopmentTools.ca_file_handles_most_https_certificates?
          safe_system HOMEBREW_BREW_FILE, "install", "ca-certificates"
        end

        args.named.each do |name|
          begin
            args = %w[--no-test]
            args << "--no-uninstall-deps" if args.include?("--no-uninstall-deps")
            safe_system HOMEBREW_BREW_FILE, "portable-install", *args, *verbose, name
            safe_system HOMEBREW_BREW_FILE, "test", *verbose, name
            puts "Linkage information:"
            safe_system HOMEBREW_BREW_FILE, "linkage", *verbose, name
            bottle_args = %w[
              --skip-relocation
              --root-url=https://ghcr.io/v2/spinel-coop/rv-ruby
              --json
              --no-rebuild
            ]
            safe_system HOMEBREW_BREW_FILE, "bottle", *verbose, *bottle_args, name
          rescue => e
            ofail e
          end
        end
      end
    end
  end
end
