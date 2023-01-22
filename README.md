# SwiftSearcher

A limited semantic search for Swift codebases.

```
sws 'func:/deletingPrefix/'

Searching 8 files
./SwiftSearcherCore/SwiftSearcher.swift 94:5
Done in: 13.663769ms
```

## Implemented Search Syntax

- Each search is comprised of a matcher and and optional filter.
- A matcher determines the type of AST node we are searching for, and filters further filter results.
- The syntax is `{matcher}|{filter}`

### Implemented matchers

- `func`, `struct`, `class`
- You can optionally specify a Swift Regex to search by the node identifier.
- E.g. All classes ending with "Manager": `class:/Manager$/`

### Implemented filters

- `modifiers`
  - Search a matched nodes modifiers as a regex. 
	- Example: Matching a function that specifies `private` or `internal`: `func:/myFunc/|modifiers:/private|internal/`
	
## Proposed Search Syntax

Note: These are proposed search terms, and may not all be implemented yet.

```
func:/my.*/
func:/myFunc/|parent:struct:/MyStruct/
func:/myFunc/|returning:/String/
struct|implementing:/MyProcotol/
func|modifiers:/private/
class|modifiers:/internal/
```

## TODO

- [ ] Add tests
