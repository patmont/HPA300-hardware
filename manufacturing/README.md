# Manufacturing artifacts

This directory contains generated outputs for revision A of the HPA300
replacement controller. Editable design sources live at the repository root;
these files are manufacturing snapshots, not source-of-truth design files.

## Fabrication

`Fabrication/` contains the two copper layers, solder masks, paste layers,
silkscreens, board outline, plated drill file, and non-plated drill file. The
release packager validates the expected manifest and puts these files alone in
the Gerber ZIP so it can be uploaded directly to a quick-turn bare-PCB vendor.

Review the vendor's rendered preview before ordering. In particular, confirm:

- 245 mm × 51 mm approximate overall outline and all internal slots
- two copper layers and 1.6 mm finished board thickness
- plated versus non-plated holes
- front and rear silkscreen orientation
- solder-mask clearances and castellated/mechanical features, if interpreted
  specially by the selected vendor

## Assembly

`Assembly/HPA300-bom.csv` is the version-controlled BOM snapshot. The external
[DigiKey list](https://www.digikey.com/en/mylists/list/1ANK154NOU) is convenient
for purchasing but can change independently of a tagged hardware release.

This is not yet a complete contract-assembly handoff. Before requesting turnkey
PCBA, generate and verify at least:

- a component placement/centroid (CPL or position) file
- assembly drawings for both sides
- rotations and package orientations against the assembler's conventions
- fitted/not-fitted status and approved substitutions
- instructions for through-hole LEDs, touch springs, connector, and mechanical
  parts

## Making a release

1. Open the project in KiCad 9 and run electrical- and design-rule checks.
2. Regenerate the schematic PDF, BOM, Gerbers, and drill files from the same
   clean revision.
3. Inspect the Gerbers in an independent viewer and compare the BOM with the
   schematic and DigiKey list.
4. Run `./scripts/package-release.ps1 -Version vX.Y.Z` and inspect `dist/`.
5. Commit the generated snapshots, tag that exact commit with `vX.Y.Z`, and
   push the tag. GitHub Actions creates the release and attaches the artifacts.

Do not create a release by combining generated outputs from different commits.
