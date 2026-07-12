# frozen_string_literal: true

require "open3"
require "rexml/document"
require "rexml/xpath"
require "tempfile"
require "tmpdir"

RSpec.describe "RSpec Atoms integration" do
  ROOT = File.expand_path("../..", __dir__)
  FIXTURE = "spec/fixtures/example_spec.rb"

  def run_cli(*arguments, chdir: ROOT)
    Open3.capture3(
      "bundle",
      "exec",
      "ruby",
      "-I#{File.join(ROOT, "lib")}",
      File.join(ROOT, "exe/rspec-atoms"),
      *arguments,
      chdir: chdir
    )
  end

  it "discovers normalized example IDs" do
    stdout, stderr, status = run_cli("discover", FIXTURE)

    expect(status).to be_success, stderr

    atoms = stdout.lines.map(&:strip)

    expect(atoms.length).to eq(2)
    expect(atoms).to all(
      match(%r{\Aspec/fixtures/example_spec\.rb\[[\d:]+\]\z})
    )
    expect(atoms).to all(
      satisfy { |atom| !atom.start_with?("./") }
    )
  end

  it "returns nonzero when no examples match" do
    _stdout, _stderr, status = run_cli(
      "discover",
      FIXTURE,
      "--example",
      "does not exist"
    )

    expect(status).not_to be_success
  end

  it "returns nonzero without printing atoms on load failure" do
    Tempfile.create(["broken", "_spec.rb"], ROOT) do |spec|
      spec.write("RSpec.describe do\n")
      spec.close

      stdout, _stderr, status = run_cli("discover", spec.path)

      expect(status).not_to be_success
      expect(stdout).to be_empty
    end
  end

  it "returns nonzero on invalid RSpec configuration" do
    stdout, _stderr, status = run_cli("discover", "--invalid-option")

    expect(status).not_to be_success
    expect(stdout).to be_empty
  end

  it "runs with automatic JUnit formatting" do
    atoms_output, discovery_error, discovery_status = run_cli(
      "discover",
      FIXTURE
    )

    expect(discovery_status).to be_success, discovery_error

    Tempfile.create(["rspec-atoms", ".xml"]) do |junit|
      _stdout, stderr, status = run_cli(
        "run",
        "--junit",
        junit.path,
        "--",
        FIXTURE
      )

      expect(status).to be_success, stderr

      document = REXML::Document.new(File.read(junit.path))
      testcases = REXML::XPath.match(document, "//testcase")

      names = testcases.map { |testcase| testcase.attributes["name"] }
      files = testcases.map { |testcase| testcase.attributes["file"] }
      classnames = testcases.map do |testcase|
        testcase.attributes["classname"]
      end

      expect(names).to include("Example suite runs normally")
      expect(names).to include(
        "Example suite when nested works from a shared example"
      )

      expect(files).to match_array(atoms_output.lines.map(&:strip))

      expect(classnames).to all(
        eq("spec.fixtures.example_spec")
      )
    end
  end

  it "preserves a failing RSpec exit status" do
    Tempfile.create(["failing", "_spec.rb"], ROOT) do |spec|
      spec.write(<<~RUBY)
        RSpec.describe "failure" do
          it("fails") { expect(1).to eq(2) }
        end
      RUBY
      spec.close

      Tempfile.create(["rspec-atoms", ".xml"]) do |junit|
        _stdout, _stderr, status = run_cli(
          "run",
          "--junit",
          junit.path,
          "--",
          spec.path
        )

        expect(status).not_to be_success
      end
    end
  end

  it "writes JUnit to the default path" do
    Dir.mktmpdir("rspec-atoms-", ROOT) do |directory|
      _stdout, stderr, status = run_cli(
        "run",
        "--",
        File.join(ROOT, FIXTURE),
        chdir: directory
      )

      expect(status).to be_success, stderr

      junit_path = File.join(directory, "tmp/rspec.xml")
      document = REXML::Document.new(File.read(junit_path))

      expect(REXML::XPath.match(document, "//testcase").length).to eq(2)
    end
  end
end
