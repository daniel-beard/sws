# SwiftSearcher

A limited semantic search for Swift codebases.

## TODO

- [x] Implement simple parser to start with
- [x] Implement types for matching and filtering
- [x] Stream output through formatters
- [x] Test on a sample project
- [ ] Get a working CI
- [ ] Add tests

## Proposed Search Syntax

TODODB: Finish writing out what I'd like this to look like

```
func:/myFunc/|parent:struct:/MyStruct/
func:/myFunc/|returning:/String/
func:/my.*/
struct|implementing:/MyProcotol/
func|modifiers:/private/
class|modifiers:/internal/
```
