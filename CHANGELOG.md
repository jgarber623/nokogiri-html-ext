# Changelog

## 0.4.2 / 2023-12-30

- Add `source_code_uri` to metadata (fd29f7c)

## 0.4.1 / 2023-12-07

- Add publish workflow (039abd0)
- Use `filter_map` instead of `compact` and `map` (ab574c9)
- Add ignored revs file (3e24d9f)
- RuboCop: address Style/StringLiterals warnings (a04b4d3)
- Update to newest rubocop-configs format (0ed51ce)
- Update RSpec configuration (#8) (4968bee)
- Update development Ruby version (#7) (0e4613a)
- Refactor CI workflow (#6) (5259b68)
- Remove CodeClimate (#5) (284fce7)

## 0.4.0 / 2023-01-20

- Improve (hopefully) handling of non-ASCII input (6d1fc4d)
- Update Nokogiri version constraint to >= 1.14 (4b7ed74)

## 0.3.1 / 2023-01-19

- Revert removal of escaping/unescaping code in relative URL resolution (a78e83a)

## 0.3.0 / 2023-01-19

- Remove escaping/unescaping code in relative URL resolution (2de6c5b)
- Remove code-scanning-rubocop and rspec-github gems (3b3e625)
- Update development Ruby to v2.7.7 (bd328f5)

## 0.2.2 / 2022-08-20

- Improve handling of escaped and invalid URLs (b0d6c75)

## 0.2.1 / 2022-08-20

- Handle escaped URLs and invalid URLs (af78837)
- Use ruby/debug gem instead of pry-byebug (4476b9d)

## 0.2.0 / 2022-07-02

- Make `resolve_relative_url` method public (d132dd3)

## 0.1.0 / 2022-07-01

- Initial release! 🎉
