# Error-Delta Example (Basic)

What we predicted:
- Adding a goal would not change existing hypotheses.

What happened:
- A hypothesis referenced the old goal list; it is now incomplete.

Delta update:
- Update `hypotheses` to reference the new goal list.
- Add a conflict entry if any downstream docs still refer to v1 goals.

