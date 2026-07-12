# RSpec Atoms

CircleCI usually splits RSpec by file. When tests run across parallel instances, a
slower feature spec can keep one worker busy while the others sit idle, even when
its individual examples are small.

Splitting a cohesive spec into several files only to satisfy the CI scheduler is
unnecessary. `rspec-atoms` exposes each runnable RSpec example as a schedulable
atom while preserving shared setup, contexts, and readable JUnit names.

The gem was designed for CircleCI's dynamic test splitting, but it works in any
environment that needs to run RSpec examples in parallel.

CircleCI Smarter Testing is currently in beta. Local validation requires the
CircleCI `testsuite` plugin; CircleCI's CI containers already include it.

## Installation

Add the gem to your `Gemfile`:

```ruby
group :test do
  gem "rspec-atoms"
end
```

Then run `bundle install`.

## CircleCI configuration

Create `.circleci/test-suites.yml`:

```yaml
---
name: backend tests

discover: >-
  RAILS_ENV=test bundle exec rspec-atoms discover spec

run: >-
  RAILS_ENV=test bundle exec rspec-atoms run
  --junit "<< outputs.junit >>"
  --
  << test.atoms >>

outputs:
  junit: /tmp/rspec/rspec.xml

options:
  dynamic-test-splitting: true
```

`<< test.atoms >>` is replaced by CircleCI with the RSpec example IDs assigned to
the current batch. `<< outputs.junit >>` resolves to the configured JUnit path so
CircleCI can locate the report. The gem enables its JUnit formatter automatically;
the `--junit` option only overrides where the report is written.

Invoke the test suite from the CircleCI job:

```yaml
- run:
    name: Run RSpec with dynamic test splitting
    command: |
      mkdir -p /tmp/rspec
      circleci run testsuite "backend tests"
    when: always

- store_test_results:
    path: /tmp/rspec
```

## Local usage

```bash
bundle exec rspec-atoms discover spec
bundle exec rspec-atoms run -- "spec/models/user_spec.rb[1:2]"
```

Local runs write JUnit XML to `tmp/rspec.xml`. Pass `--junit PATH` before `--` to
use a different path.

Validate the CircleCI configuration locally with:

```bash
circleci run testsuite "backend tests" --doctor
```
