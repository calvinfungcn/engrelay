# label-normalization Specification

## ADDED Requirements

### Requirement: Normalize demo labels

`Normalize-DemoLabels` SHALL accept a string array of labels and return a new
string array object where:

- each label is trimmed of leading and trailing whitespace;
- labels that are empty after trimming are removed;
- a duplicate is detected case-insensitively, only its first occurrence is kept,
  and that occurrence's spelling is used;
- the kept labels stay in input order.

The result SHALL be an array object for every input, including an empty result and a
single-item result. A caller that captures the function output directly SHALL receive
that array object, not `$null` and not an unrolled scalar.

#### Scenario: Empty input

- **WHEN** the input is an empty array
- **THEN** the result is an empty array object

#### Scenario: Case-insensitive duplicates

- **WHEN** the input is `[" Alpha ", "alpha", "BETA", "beta"]`
- **THEN** the result is `["Alpha", "BETA"]`

#### Scenario: Blank values

- **WHEN** the input is `[" ", "", " a "]`
- **THEN** the result is `["a"]`

#### Scenario: First spelling kept

- **WHEN** the input is `["b", "A", "b", "c"]`
- **THEN** the result is `["b", "A", "c"]`
