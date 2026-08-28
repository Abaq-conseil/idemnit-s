class Indemnite {
  final int idPersonne;
  final int idType;
  final int? idTarifKilometrique;

  final double? montantCalculer;
  final double? montantSaisie;

  final DateTime? dateIndemnisation;

  final String? titre;
  final String? preuve;
  final String motif;

  final String? depart;
  final String? arrivee;
  final bool? allerRetour;
  final double? distanceKm;

  final double? ht;
  final double? tva;
  final double? ttc;

  const Indemnite({
    required this.idPersonne,
    required this.idType,
    this.idTarifKilometrique,
    this.montantCalculer,
    this.montantSaisie,
    this.dateIndemnisation,
    this.titre,
    this.preuve,
    required this.motif,
    this.depart,
    this.arrivee,
    this.allerRetour,
    this.distanceKm,
    this.ht,
    this.tva,
    this.ttc,
  });

  Map<String, dynamic> toMap() {
    return {
      'id_personne': idPersonne,
      'id_type': idType,
      'id_tarif_kilometrique': idTarifKilometrique,

      'montant_calculer': montantCalculer,
      'montant_saisie': montantSaisie,

      'date_indemnisation': dateIndemnisation
          ?.toIso8601String()
          .split('T')
          .first,

      'titre': titre,
      'preuve': preuve,
      'motif': motif,

      'depart': depart,
      'arivee': arrivee,
      'allee_retour': allerRetour,
      'distance_km': distanceKm,

      'HT': ht,
      'TVA': tva,
      'TTC': ttc,
    };
  }

  factory Indemnite.fromMap(Map<String, dynamic> map) {
    return Indemnite(
      idPersonne: map['id_personne'] as int,
      idType: map['id_type'] as int,

      idTarifKilometrique:
      map['id_tarif_kilometrique'] as int?,

      montantCalculer: map['montant_calculer'] == null
          ? null
          : double.tryParse(
        map['montant_calculer'].toString(),
      ),

      montantSaisie: map['montant_saisie'] == null
          ? null
          : double.tryParse(
        map['montant_saisie'].toString(),
      ),

      dateIndemnisation: map['date_indemnisation'] == null
          ? null
          : DateTime.tryParse(
        map['date_indemnisation'].toString(),
      ),

      titre: map['titre']?.toString(),

      preuve: map['preuve']?.toString(),

      motif: map['motif']?.toString() ?? '',

      depart: map['depart']?.toString(),

      arrivee: map['arivee']?.toString(),

      allerRetour: map['allee_retour'] as bool?,

      distanceKm: map['distance_km'] == null
          ? null
          : double.tryParse(
        map['distance_km'].toString(),
      ),

      ht: map['HT'] == null
          ? null
          : double.tryParse(
        map['HT'].toString(),
      ),

      tva: map['TVA'] == null
          ? null
          : double.tryParse(
        map['TVA'].toString(),
      ),

      ttc: map['TTC'] == null
          ? null
          : double.tryParse(
        map['TTC'].toString(),
      ),
    );
  }
}