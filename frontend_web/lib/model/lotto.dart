class Lotto {
  int idLotto;
  String coltura;
  DateTime dataSemina;
  DateTime dataConsegna;
  int piante;
  int vassoi;
  List<dynamic> scansioni;
  int fallanza;
  bool consegnato;

  Lotto({
    required this.idLotto,
    required this.coltura,
    required this.dataSemina,
    required this.dataConsegna,
    required this.piante,
    required this.vassoi,
    this.scansioni = const [],
    this.fallanza = 0,
    this.consegnato = false,
  });

  factory Lotto.fromJson(Map<String, dynamic> json) {
    return Lotto(
      idLotto: json['id_lotto'],
      coltura: json['coltura'] ?? 'Nessuna coltura assegnata',
      dataSemina: DateTime.fromMillisecondsSinceEpoch(json['data_semina']),
      dataConsegna: DateTime.fromMillisecondsSinceEpoch(json['data_consegna']),
      piante: json['piante'] ?? 0,
      vassoi: json['vassoi'] ?? 0,
      scansioni: json['scansioni'] ?? [],
      fallanza: json['fallanza'] ?? 0,
      consegnato: json['consegnato'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_lotto': idLotto,
      'coltura': coltura,
      'data_semina': dataSemina.millisecondsSinceEpoch,
      'data_consegna': dataConsegna.millisecondsSinceEpoch,
      'piante': piante,
      'vassoi': vassoi,
      'scansioni': scansioni,
      'fallanza': fallanza,
      'consegnato': consegnato,
    };
  }
}
