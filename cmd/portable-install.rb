# typed: strict
# frozen_string_literal: true

require "abstract_command"
require "development_tools"
require "dependency"

module Homebrew
  module Cmd
    class PortableInstallCmd < AbstractCommand
      cmd_args do
        usage_banner <<~EOS
          `portable-install` <formulae>

          Build portable formulae.
        EOS
        switch "--no-test", description: "Skip testing after install"
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
          name = "portable-#{name}" unless name.start_with? "portable-"
          begin
            # On Linux, install glibc and linux-headers from bottles and don't install their build dependencies.
            bottled_dep_allowlist = /\A(?:glibc@.*|linux-headers@.*|rust|rustup|pkgconf)\z/
            deps = Dependency.expand(Formula[name], cache_key: "portable-package-#{name}") do |_dependent, dep|
              Dependency.prune if dep.test? || dep.optional?

              next unless bottled_dep_allowlist.match?(dep.name)

              Dependency.keep_but_prune_recursive_deps
            end.map(&:name)

            bottled_deps, deps = deps.partition { |dep| bottled_dep_allowlist.match?(dep) }
            puts "Bottled deps: #{bottled_deps.inspect}"
            puts "Other deps: #{deps.inspect}"

            safe_system HOMEBREW_BREW_FILE, "install", *verbose, *bottled_deps if bottled_deps.present?

            # Build bottles for all other dependencies.
            safe_system HOMEBREW_BREW_FILE, "install", "--build-bottle", *verbose, *deps

            safe_system HOMEBREW_BREW_FILE, "install", "--build-bottle", *verbose, name
            safe_system HOMEBREW_BREW_FILE, "test", *verbose, name unless args.no_test?
            unless args.no_uninstall_deps?
              safe_system HOMEBREW_BREW_FILE, "uninstall", "--force", "--ignore-dependencies", *verbose, *deps
            end
          rescue => e
            ofail e
          end
        end
      end
    end
  end
end
