# SwiftSearcher

A limited semantic search for Swift codebases.

## TODO

- [x] Implement simple parser to start with
- [ ] Implement types for matching and filtering
- [ ] Stream output through formatters
- [ ] Test on a sample project
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
