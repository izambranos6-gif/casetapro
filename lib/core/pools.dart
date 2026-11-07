/// Catálogo fijo de piscinas, separado del modelo para futura integración API.
class Pools {
  static const zone1 = <String>[
    'IS001','IS002','IS062','IS079','IS080','IS082',
    'IS083','IS084','IS085','IS086','IS089','IS091',
    'IS092','IS093','IS094','IS098','IS099','IS100',
    'IS144','IS145','IS146','IS147','IS151','IS152',
  ];

  static const zone2 = <String>[
    'IS006','IS007','IS045','IS046','IS048','IS049',
    'IS050','IS051','IS053','IS054','IS055','IS057',
    'IS061','IS065','IS066','IS067','IS068','IS073',
    'IS074','IS078','IS142','IS148',
  ];

  static List<String> forZone(int zone) => switch (zone) {
    1 => zone1,
    2 => zone2,
    _ => throw ArgumentError.value(zone, 'zone', 'La zona debe ser 1 o 2'),
  };

  static bool belongsTo(int zone, String pool) => forZone(zone).contains(pool);
}
