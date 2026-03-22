# Blackmatter Android - home-manager module aggregator
{ hmToolHelpers }:
{ ... }: {
  imports = [
    (import ./android { inherit hmToolHelpers; })
  ];
}
