class Lotto {
  String idLotto;
  String coltura;
  String dataSemina;
  String dataConsegna;
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
      dataSemina: json['data_semina'] ?? 'Nessuna data assegnata',
      dataConsegna: json['data_consegna'] ?? 'Nessuna data assegnata',
      piante: json['piante'] ?? 'Nessuna pianta assegnata',
      vassoi: json['vassoi'] ?? 'Nessun vassoio assegnato',
      scansioni: json['scansioni'] ?? [],
      fallanza: json['fallanza'] ?? 0,
      consegnato: json['consegnato'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_lotto': idLotto,
      'coltura': coltura,
      'data_semina': dataSemina,
      'data_consegna': dataConsegna,
      'piante': piante,
      'vassoi': vassoi,
      'scansioni': scansioni,
      'fallanza': fallanza,
      'consegnato': consegnato,
    };
  }
}
