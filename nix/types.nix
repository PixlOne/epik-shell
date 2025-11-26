{ lib }:
with lib;
{
  direction =
    let
      verticals = [ "top" "bottom" ];
      horizontals = [ "left" "right" ];
    in
    {
      vertical = types.enum verticals;
      all = types.enum
        (
          lists.concatLists
            ([ verticals horizontals [ "center" ] ]
              ++ (map (y: (map (x: "${y}_${x}") horizontals)) verticals)
            ));
    };

  modules = types.enum [
    "launcher"
    "workspace"
    "time"
    "notification"
    "network_speed"
    "quicksetting"
  ];

  xy = with types; addCheck (listOf int) (l: length l == 2);
}
