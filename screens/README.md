# Mocklens Screens

This folder contains static mobile UI mockups. Each HTML file is an independent screen or state.

- Keep screens plain HTML/CSS with local assets only.
- Link `./shared.css` for shared tokens and base components.
- Name variants `<screen>.<device>.html`; use `mocklens new-screen <name> --device <device>` instead of copying boilerplate.
- Keep the generated `mocklens:*` metadata in the document head accurate. Device names must exist in `mocklens.config.json`.
- Run `mocklens list` to confirm discovery and `mocklens check` before handoff.
- If overflow is intentional, add `data-mocklens-ignore="short reason"` to the element.
