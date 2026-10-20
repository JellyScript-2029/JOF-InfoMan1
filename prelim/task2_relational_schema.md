# Task 2 — Relational Schema (ToolShare)

Notation: primary keys are underlined with `<u>…</u>`, foreign keys are marked `[FK]`.

Member(<u>member_id</u>, member_name, phone, join_date)

StorageLocation(<u>location_code</u>, description)

Tool(<u>tool_id</u>, tool_name, category, purchase_date, location_code [FK → StorageLocation])

Certification(<u>cert_id</u>, cert_name)

Borrowing(<u>borrow_id</u>, member_id [FK → Member], tool_id [FK → Tool], borrow_date, return_date)

MemberCertification(<u>member_id</u> [FK → Member], <u>cert_id</u> [FK → Certification], completion_date)

ToolRequirement(<u>tool_id</u> [FK → Tool], <u>cert_id</u> [FK → Certification])


## Resolution of the conceptual ERD

| Conceptual construct | Resolved as |
|---|---|
| Member M:N Tool ("borrows") | the `Borrowing` junction table. `borrow_date` and `return_date` are kept here because they describe the loan itself, not the member or the tool |
| Member M:N Certification ("completes") | the `MemberCertification` junction table, with `completion_date` as its extra attribute |
| Tool M:N Certification ("requires") | the `ToolRequirement` junction table. It only needs the two FKs, nothing extra |
| StorageLocation 1:N Tool ("stores") | `location_code` goes on the Tool side as an FK, since Tool is the "many" side. It is NOT NULL because every tool must have a location (total participation) |
| Weak entities / multivalued attributes | none in the spec. `member_name` stays as one simple attribute, and each member only has one phone number, so there is nothing multivalued to handle |

## Key decisions
- **Borrowing gets a surrogate PK (`borrow_id`).** The spec says a member may borrow many tools over time and a tool may be borrowed by many members over its lifetime, so the same member is allowed to borrow the same tool more than once. If I keyed Borrowing on (member_id, tool_id), a repeat loan would violate the key, so that combination can't be the PK.
- **MemberCertification and ToolRequirement use composite PKs.** Repeating is not allowed in these two: a member completes a given certification once, and a tool requires a given certification once, so (member_id, cert_id) and (tool_id, cert_id) are enough to identify a row.
- **One business rule can't be enforced with keys/FKs alone:** "a member cannot borrow a tool requiring a certification they have not completed." The schema still stores everything needed to check the rule (the two certification junction tables), but actually enforcing it would need a trigger or application logic, which is past what the Weeks 1–5 DDL can do.

## Validation against the spec
- Member: ID, name, phone, start date -> covered
- Tool: ID, name, category, purchase date -> covered
- Borrowing event: borrow date and return date, where return_date is NULL while the tool is still on loan -> covered
- Certifications: many-to-many with tools, plus a completion date per member -> covered
- Storage location: code and description; every tool has exactly one location, and a location can hold zero tools -> covered
