import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/indemnite.dart';
import '../services/supabase_service.dart';

class AjouterIndemniteScreen extends StatefulWidget {
  final int idPersonne;

  // null = ajout
  // non-null = modification
  final Map<String, dynamic>? indemniteExistante;

  const AjouterIndemniteScreen({
    super.key,
    required this.idPersonne,
    this.indemniteExistante,
  });

  bool get modeModification =>
      indemniteExistante != null;

  @override
  State<AjouterIndemniteScreen> createState() =>
      _AjouterIndemniteScreenState();
}

class _AjouterIndemniteScreenState
    extends State<AjouterIndemniteScreen> {
  final SupabaseService _supabaseService = SupabaseService();

  final _formKey = GlobalKey<FormState>();

  void _calculerTtc() {
    final ht = double.tryParse(
      htController.text.replaceAll(',', '.'),
    );

    final tva = double.tryParse(
      tvaController.text.replaceAll(',', '.'),
    );

    if (ht == null || tva == null) {
      ttcController.text = '';
      return;
    }

    final ttc = ht + tva;

    ttcController.text = ttc.toStringAsFixed(2);
  }

  bool _validationLancee = false;

  bool _enregistrementEnCours = false;

  String typeIndemnite = 'Indemnités kilométriques';

  bool allerRetour = false;

  DateTime? dateIndemnisation;

  PlatformFile? preuve;

  String? anciennePreuve;

  bool supprimerAnciennePreuve = false;

  final departController = TextEditingController();

  final arriveeController = TextEditingController();

  final distanceController = TextEditingController();

  final htController = TextEditingController();

  final tvaController = TextEditingController();

  final ttcController = TextEditingController();

  final motifController = TextEditingController();

  final titreController = TextEditingController();

  // ================================================================
  // INIT
  // ================================================================

  @override
  void initState() {
    super.initState();

    _chargerIndemniteExistante();
  }

  void _chargerIndemniteExistante() {
    final data = widget.indemniteExistante;

    if (data == null) {
      return;
    }

    // --------------------------------------------------------------
    // TYPE
    // --------------------------------------------------------------

    final idType = data['id_type'];

    switch (idType) {
      case 1:
        typeIndemnite = 'Restauration';
        break;

      case 2:
        typeIndemnite = 'Indemnités kilométriques';
        break;

      case 3:
        typeIndemnite = 'Autre';
        break;

      case 4:
        typeIndemnite = 'Péage / Parking';
        break;
    }

    // --------------------------------------------------------------
    // TITRE
    // --------------------------------------------------------------

    titreController.text =
        data['titre']?.toString() ?? '';

    // --------------------------------------------------------------
    // MOTIF
    // --------------------------------------------------------------

    motifController.text =
        data['motif']?.toString() ?? '';

    // --------------------------------------------------------------
    // DEPART
    // --------------------------------------------------------------

    departController.text =
        data['depart']?.toString() ?? '';

    // --------------------------------------------------------------
    // ARRIVEE
    // --------------------------------------------------------------

    arriveeController.text =
        data['arivee']?.toString() ?? '';

    // --------------------------------------------------------------
    // DISTANCE
    // --------------------------------------------------------------

    if (data['distance_km'] != null) {
      distanceController.text =
          data['distance_km'].toString();
    }

// --------------------------------------------------------------
// HT
// --------------------------------------------------------------

    if (data['HT'] != null) {
      htController.text = data['HT'].toString();
    }

// --------------------------------------------------------------
// TVA
// --------------------------------------------------------------

    if (data['TVA'] != null) {
      tvaController.text = data['TVA'].toString();
    }

// --------------------------------------------------------------
// TTC
// --------------------------------------------------------------

    if (data['TTC'] != null) {
      ttcController.text = data['TTC'].toString();
    }
    // --------------------------------------------------------------
    // ALLER RETOUR
    // --------------------------------------------------------------

    allerRetour =
        data['allee_retour'] == true;

    // --------------------------------------------------------------
    // DATE
    // --------------------------------------------------------------

    if (data['date_indemnisation'] != null) {
      dateIndemnisation =
          DateTime.tryParse(
            data['date_indemnisation'].toString(),
          );
    }

    // --------------------------------------------------------------
    // PREUVE
    // --------------------------------------------------------------

    anciennePreuve =
        data['preuve']?.toString();
  }

  // ================================================================
  // DISPOSE
  // ================================================================

  @override
  void dispose() {
    departController.dispose();
    arriveeController.dispose();
    distanceController.dispose();
    htController.dispose();
    tvaController.dispose();
    ttcController.dispose();
    motifController.dispose();
    titreController.dispose();

    super.dispose();
  }

  // ================================================================
  // BUILD
  // ================================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
      const Color(0xFFF5F9FC),

      appBar: AppBar(
        backgroundColor:
        const Color(0xFFF5F9FC),
        elevation: 0,

        title: Text(
          widget.modeModification
              ? 'Modifier une indemnité'
              : 'Ajouter une indemnité',

          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding:
        const EdgeInsets.all(20),

        child: Form(
          key: _formKey,

          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,

            children: [
              const Text(
                'Type d’indemnité',

                style: TextStyle(
                  fontSize: 16,
                  fontWeight:
                  FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              DropdownButtonFormField<String>(
                initialValue:
                typeIndemnite,

                decoration:
                InputDecoration(
                  filled: true,
                  fillColor:
                  Colors.white,

                  border:
                  OutlineInputBorder(
                    borderRadius:
                    BorderRadius.circular(
                      10,
                    ),
                  ),
                ),

                items: const [
                  DropdownMenuItem(
                    value:
                    'Indemnités kilométriques',

                    child: Text(
                      'Indemnités kilométriques',
                    ),
                  ),

                  DropdownMenuItem(
                    value: 'Restauration',

                    child: Text(
                      'Restauration',
                    ),
                  ),

                  DropdownMenuItem(
                    value:
                    'Péage / Parking',

                    child: Text(
                      'Péage / Parking',
                    ),
                  ),

                  DropdownMenuItem(
                    value: 'Autre',

                    child: Text(
                      'Autre',
                    ),
                  ),
                ],

                onChanged:
                _enregistrementEnCours
                    ? null
                    : (value) {
                  if (value ==
                      null) {
                    return;
                  }

                  setState(() {
                    typeIndemnite =
                        value;

                    // Nettoyage des champs
                    // lorsqu'on change de type.
                    if (value !=
                        'Indemnités kilométriques') {
                      departController
                          .clear();

                      arriveeController
                          .clear();

                      distanceController
                          .clear();

                      allerRetour =
                      false;
                    }
                  });
                },
              ),

              const SizedBox(
                height: 30,
              ),

              _buildChampsSelonType(),
            ],
          ),
        ),
      ),
    );
  }

  // ================================================================
  // CHAMPS SELON TYPE
  // ================================================================

  Widget _buildChampsSelonType() {
    switch (typeIndemnite) {
      case 'Indemnités kilométriques':
        return _buildChampsKilometriques();

      case 'Restauration':
        return _buildChampsRestauration();

      case 'Péage / Parking':
        return _buildChampsPeageParking();

      case 'Autre':
        return _buildChampsAutre();

      default:
        return const SizedBox();
    }
  }

  // ================================================================
  // KILOMETRIQUE
  // ================================================================

  Widget _buildChampsKilometriques() {
    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,

      children: [
        _champ(
          'Départ',
          controller:
          departController,

          validator: (value) {
            if (value == null ||
                value.trim().isEmpty) {
              return 'Le départ est obligatoire';
            }

            return null;
          },
        ),

        _champ(
          'Arrivée',
          controller:
          arriveeController,

          validator: (value) {
            if (value == null ||
                value.trim().isEmpty) {
              return 'L’arrivée est obligatoire';
            }

            return null;
          },
        ),

        _champ(
          'Distance (km)',
          controller:
          distanceController,

          keyboardType:
          const TextInputType.numberWithOptions(
            decimal: true,
          ),

          validator:
          _validerDistance,
        ),

        const SizedBox(height: 5),

        CheckboxListTile(
          contentPadding:
          EdgeInsets.zero,

          title: const Text(
            'Aller-retour',
          ),

          value: allerRetour,

          onChanged:
          _enregistrementEnCours
              ? null
              : (value) {
            setState(() {
              allerRetour =
                  value ??
                      false;
            });
          },
        ),

        const SizedBox(height: 5),

        _champDate(),

        _champMotif(),

        _champPreuve(),

        _boutonEnregistrer(),

        const SizedBox(
          height: 40,
        ),
      ],
    );
  }

  // ================================================================
  // RESTAURATION
  // ================================================================

  Widget _buildChampsRestauration() {
    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,

      children: [
        _buildChampsMontants(),

        _champDate(),

        _champMotif(),

        _champPreuve(),

        const SizedBox(
          height: 20,
        ),

        _boutonEnregistrer(),
      ],
    );
  }

  // ================================================================
  // PEAGE / PARKING
  // ================================================================

  Widget _buildChampsPeageParking() {
    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,

      children: [
        _buildChampsMontants(),

        _champDate(),

        _champMotif(),

        _champPreuve(),

        const SizedBox(
          height: 20,
        ),

        _boutonEnregistrer(),
      ],
    );
  }

  // ================================================================
  // AUTRE
  // ================================================================

  Widget _buildChampsAutre() {
    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,

      children: [
        _champ(
          'Titre',
          controller:
          titreController,

          validator: (value) {
            if (value == null ||
                value.trim().isEmpty) {
              return 'Le titre est obligatoire';
            }

            return null;
          },
        ),

        _buildChampsMontants(),

        _champDate(),

        _champMotif(),

        _champPreuve(),

        const SizedBox(
          height: 20,
        ),

        _boutonEnregistrer(),
      ],
    );
  }

  // ================================================================
  // CHAMP
  // ================================================================

  Widget _champ(
      String label, {
        TextEditingController? controller,
        TextInputType? keyboardType,
        String? Function(String?)? validator,
        void Function(String)? onChanged,
        bool readOnly = false,
      }) {
    return Padding(
      padding:
      const EdgeInsets.only(
        bottom: 15,
      ),

      child: TextFormField(
        controller: controller,

        onChanged: onChanged,
        readOnly: readOnly,

        keyboardType:
        keyboardType,

        validator: validator,

        decoration:
        InputDecoration(
          labelText: label,

          filled: true,
          fillColor:
          Colors.white,

          border:
          OutlineInputBorder(
            borderRadius:
            BorderRadius.circular(
              10,
            ),
          ),
        ),
      ),
    );
  }

  // ================================================================
  // VALIDATION MONTANT
  // ================================================================

  String? _validerMontant(
      String? value,
      ) {
    if (value == null ||
        value.trim().isEmpty) {
      return 'Le montant est obligatoire';
    }

    final montant =
    double.tryParse(
      value
          .replaceAll(',', '.')
          .trim(),
    );

    if (montant == null) {
      return 'Veuillez saisir un montant valide';
    }

    if (montant <= 0) {
      return 'Le montant doit être supérieur à 0';
    }

    return null;
  }

  // ================================================================
  // VALIDATION DISTANCE
  // ================================================================

  String? _validerDistance(
      String? value,
      ) {
    if (value == null ||
        value.trim().isEmpty) {
      return 'La distance est obligatoire';
    }

    final distance =
    double.tryParse(
      value
          .replaceAll(',', '.')
          .trim(),
    );

    if (distance == null) {
      return 'Veuillez saisir un nombre valide';
    }

    if (distance <= 0) {
      return 'La distance doit être supérieure à 0';
    }

    return null;
  }

  // ================================================================
  // DATE
  // ================================================================

  Future<void> _selectionnerDate() async {
    final date =
    await showDatePicker(
      context: context,

      initialDate:
      dateIndemnisation ??
          DateTime.now(),

      firstDate:
      DateTime(2020),

      lastDate:
      DateTime(2100),
    );

    if (date != null) {
      setState(() {
        dateIndemnisation =
            date;
      });
    }
  }

  Widget _champDate() {
    return Padding(
      padding:
      const EdgeInsets.only(
        bottom: 15,
      ),

      child: InkWell(
        onTap:
        _enregistrementEnCours
            ? null
            : _selectionnerDate,

        child: InputDecorator(
          decoration:
          InputDecoration(
            labelText: 'Date',

            filled: true,
            fillColor:
            Colors.white,

            border:
            OutlineInputBorder(
              borderRadius:
              BorderRadius.circular(
                10,
              ),
            ),

            suffixIcon:
            const Icon(
              Icons.calendar_today,
            ),

            errorText:
            _validationLancee &&
                dateIndemnisation ==
                    null
                ? 'La date est obligatoire'
                : null,
          ),

          child: Text(
            _afficherDate(),

            style: TextStyle(
              color:
              dateIndemnisation ==
                  null
                  ? Colors.grey
                  : Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  String _afficherDate() {
    if (dateIndemnisation ==
        null) {
      return 'Sélectionner une date';
    }

    final jour =
    dateIndemnisation!
        .day
        .toString()
        .padLeft(2, '0');

    final mois =
    dateIndemnisation!
        .month
        .toString()
        .padLeft(2, '0');

    final annee =
        dateIndemnisation!
            .year;

    return '$jour/$mois/$annee';
  }

  // ================================================================
  // MOTIF
  // ================================================================

  Widget _champMotif() {
    return Padding(
      padding:
      const EdgeInsets.only(
        bottom: 15,
      ),

      child: TextFormField(
        controller:
        motifController,

        maxLines: 5,

        validator: (value) {
          if (value == null ||
              value.trim().isEmpty) {
            return 'Le motif est obligatoire';
          }

          return null;
        },

        decoration:
        InputDecoration(
          labelText: 'Motif',

          alignLabelWithHint:
          true,

          filled: true,
          fillColor:
          Colors.white,

          border:
          OutlineInputBorder(
            borderRadius:
            BorderRadius.circular(
              10,
            ),
          ),
        ),
      ),
    );
  }

  // ================================================================
  // PREUVE
  // ================================================================

  Future<void> _choisirPreuve() async {
    await showModalBottomSheet(
      context: context,

      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize:
            MainAxisSize.min,

            children: [
              ListTile(
                leading:
                const Icon(
                  Icons.insert_drive_file,
                ),

                title:
                const Text(
                  'Choisir un fichier',
                ),

                onTap: () {
                  Navigator.pop(
                    context,
                  );

                  _selectionnerFichier();
                },
              ),

              ListTile(
                leading:
                const Icon(
                  Icons.camera_alt,
                ),

                title:
                const Text(
                  'Prendre une photo',
                ),

                onTap: () {
                  Navigator.pop(
                    context,
                  );

                  _prendrePhoto();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // ================================================================
  // FICHIER
  // ================================================================

  Future<void> _selectionnerFichier() async {
    try {
      final result =
      await FilePicker.platform
          .pickFiles(
        type: FileType.any,

        allowMultiple:
        false,

        withData: true,
      );

      if (result == null ||
          result.files.isEmpty) {
        return;
      }

      final fichier =
          result.files.first;

      if (fichier.bytes == null) {
        throw Exception(
          'Impossible de lire le fichier sélectionné.',
        );
      }

      setState(() {
        preuve = fichier;

        supprimerAnciennePreuve =
        false;
      });
    } catch (e) {
      _afficherErreur(e);
    }
  }

  // ================================================================
  // PHOTO
  // ================================================================

  Future<void> _prendrePhoto() async {
    try {
      final picker =
      ImagePicker();

      final photo =
      await picker.pickImage(
        source:
        ImageSource.camera,

        imageQuality: 85,
      );

      if (photo == null) {
        return;
      }

      final Uint8List bytes =
      await photo.readAsBytes();

      setState(() {
        preuve = PlatformFile(
          name:
          'photo_${DateTime.now().millisecondsSinceEpoch}.jpg',

          size: bytes.length,

          bytes: bytes,
        );

        supprimerAnciennePreuve =
        false;
      });
    } catch (e) {
      _afficherErreur(e);
    }
  }

  // ================================================================
  // AFFICHER ERREUR
  // ================================================================

  void _afficherErreur(
      Object e,
      ) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(
      SnackBar(
        content: Text(
          'Erreur : $e',
        ),
      ),
    );
  }

  // ================================================================
  // WIDGET PREUVE
  // ================================================================

  Widget _champPreuve() {
    final nouvellePreuve =
        preuve != null;

    return Padding(
      padding:
      const EdgeInsets.only(
        bottom: 15,
      ),

      child: Column(
        children: [
          OutlinedButton(
            onPressed:
            _enregistrementEnCours
                ? null
                : _choisirPreuve,

            style:
            OutlinedButton.styleFrom(
              minimumSize:
              const Size(
                double.infinity,
                55,
              ),

              alignment:
              Alignment.centerLeft,

              shape:
              RoundedRectangleBorder(
                borderRadius:
                BorderRadius.circular(
                  10,
                ),
              ),
            ),

            child: Row(
              children: [
                const Icon(
                  Icons.attach_file,
                ),

                const SizedBox(
                  width: 10,
                ),

                Expanded(
                  child: Text(
                    nouvellePreuve
                        ? preuve!.name
                        : anciennePreuve !=
                        null &&
                        !supprimerAnciennePreuve
                        ? 'Preuve existante'
                        : 'Ajouter une preuve',

                    overflow:
                    TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          if (anciennePreuve !=
              null &&
              !nouvellePreuve &&
              !supprimerAnciennePreuve)
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Une preuve est déjà enregistrée.',
                  ),
                ),

                TextButton(
                  onPressed:
                  _enregistrementEnCours
                      ? null
                      : () {
                    setState(() {
                      supprimerAnciennePreuve =
                      true;
                    });
                  },

                  child:
                  const Text(
                    'Supprimer',
                  ),
                ),
              ],
            ),

          if (supprimerAnciennePreuve)
            const Align(
              alignment:
              Alignment.centerLeft,

              child: Text(
                'La preuve sera supprimée.',
                style: TextStyle(
                  color: Colors.red,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ================================================================
  // BOUTON
  // ================================================================

  Widget _boutonEnregistrer() {
    return SizedBox(
      width:
      double.infinity,

      height: 50,

      child: ElevatedButton(
        onPressed:
        _enregistrementEnCours
            ? null
            : _enregistrer,

        child:
        _enregistrementEnCours
            ? const SizedBox(
          width: 22,
          height: 22,

          child:
          CircularProgressIndicator(
            strokeWidth: 2,
          ),
        )
            : Text(
          widget.modeModification
              ? 'Enregistrer les modifications'
              : 'Enregistrer',

          style:
          const TextStyle(
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  // ================================================================
  // ENREGISTRER
  // ================================================================

  Future<void> _enregistrer() async {
    setState(() {
      _validationLancee =
      true;
    });

    final formulaireValide =
    _formKey.currentState!
        .validate();

    if (!formulaireValide) {
      return;
    }

    if (dateIndemnisation ==
        null) {
      return;
    }

    setState(() {
      _enregistrementEnCours =
      true;
    });

    String? nouvellePreuveChemin;

    try {
      // ------------------------------------------------------------
      // ID TYPE
      // ------------------------------------------------------------

      final int idType;

      switch (typeIndemnite) {
        case 'Restauration':
          idType = 1;
          break;

        case 'Indemnités kilométriques':
          idType = 2;
          break;

        case 'Autre':
          idType = 3;
          break;

        case 'Péage / Parking':
          idType = 4;
          break;

        default:
          throw Exception(
            'Type d’indemnité inconnu.',
          );
      }

      // ------------------------------------------------------------
      // MONTANT SAISI
      // ------------------------------------------------------------

      double? ht;
      double? tva;
      double? ttc;

      if (typeIndemnite == 'Indemnités kilométriques') {
        // Pour les indemnités kilométriques,
        // le montant est calculé par la BDD.
        ht = null;
        tva = 0;
        ttc = null;
      } else {
        ht = double.tryParse(
          htController.text.trim().replaceAll(',', '.'),
        );

        tva = double.tryParse(
          tvaController.text.trim().replaceAll(',', '.'),
        );

        ttc = double.tryParse(
          ttcController.text.trim().replaceAll(',', '.'),
        );
      }

      // ------------------------------------------------------------
      // DISTANCE
      // ------------------------------------------------------------

      double? distanceKm;

      if (distanceController
          .text
          .trim()
          .isNotEmpty) {
        distanceKm =
            double.tryParse(
              distanceController.text
                  .trim()
                  .replaceAll(
                ',',
                '.',
              ),
            );
      }

      // ------------------------------------------------------------
      // TARIF KILOMETRIQUE
      // ------------------------------------------------------------

      int? idTarifKilometrique;

      if (typeIndemnite ==
          'Indemnités kilométriques') {
        final personne =
        await _supabaseService
            .getPersonne(
          widget.idPersonne,
        );

        if (personne == null) {
          throw Exception(
            'Personne introuvable.',
          );
        }

        final puissance =
        (personne[
        'nb_chevaux_vehicule']
        as num)
            .toInt();

        final tarif =
        await _supabaseService
            .getTarifKilometrique(
          puissance,
        );

        if (tarif == null) {
          throw Exception(
            'Aucun tarif kilométrique trouvé pour '
                '$puissance CV.',
          );
        }

        idTarifKilometrique =
            (tarif[
            'id_tarif_kilometrique']
            as num)
                .toInt();
      }

      // ------------------------------------------------------------
      // PREUVE
      // ------------------------------------------------------------

      String? cheminPreuve =
          anciennePreuve;

      // Nouvelle preuve
      if (preuve != null) {
        if (preuve!.bytes == null) {
          throw Exception(
            'Impossible de lire la preuve.',
          );
        }

        nouvellePreuveChemin =
        await _supabaseService
            .envoyerPreuve(
          bytes: preuve!.bytes!,
          nomFichier:
          preuve!.name,
          idPersonne:
          widget.idPersonne,
        );

        cheminPreuve =
            nouvellePreuveChemin;
      }

      // Suppression demandée
      if (supprimerAnciennePreuve) {
        cheminPreuve = null;
      }

      // ============================================================
      // AJOUT
      // ============================================================

      if (!widget.modeModification) {
        final indemnite =
        Indemnite(
          idPersonne:
          widget.idPersonne,

          idType: idType,

          idTarifKilometrique:
          idTarifKilometrique,

          // Pour kilométrique :
          // le trigger PostgreSQL calcule montant_calculer.
          montantCalculer: null,

          montantSaisie: null,

          ht: ht,
          tva: tva,
          ttc: ttc,

          dateIndemnisation:
          dateIndemnisation,

          titre:
          titreController.text
              .trim()
              .isEmpty
              ? null
              : titreController.text
              .trim(),

          preuve:
          cheminPreuve,

          motif:
          motifController.text
              .trim(),

          depart:
          typeIndemnite ==
              'Indemnités kilométriques'
              ? departController
              .text
              .trim()
              : null,

          arrivee:
          typeIndemnite ==
              'Indemnités kilométriques'
              ? arriveeController
              .text
              .trim()
              : null,

          allerRetour:
          typeIndemnite ==
              'Indemnités kilométriques'
              ? allerRetour
              : null,

          distanceKm:
          typeIndemnite ==
              'Indemnités kilométriques'
              ? distanceKm
              : null,
        );

        try {
          await _supabaseService
              .ajouterIndemnite(
            indemnite,
          );
        } catch (e) {
          // Si l'insert échoue, on nettoie
          // le fichier nouvellement uploadé.
          if (nouvellePreuveChemin !=
              null) {
            try {
              await _supabaseService
                  .supprimerPreuve(
                nouvellePreuveChemin,
              );
            } catch (_) {}
          }

          rethrow;
        }
      }

      // ============================================================
      // MODIFICATION
      // ============================================================

      else {
        final idIndemnisation =
        (widget.indemniteExistante![
        'id_indemnisation']
        as num)
            .toInt();

        await _supabaseService
            .modifierIndemnite(
          idIndemnisation,
          {
            'id_type': idType,

            'id_tarif_kilometrique':
            idTarifKilometrique,

            'montant_saisie': null,

            'HT': ht,
            'TVA': tva,
            'TTC': ttc,

            'date_indemnisation':
            dateIndemnisation!
                .toIso8601String()
                .split('T')
                .first,

            'titre':
            titreController.text
                .trim()
                .isEmpty
                ? null
                : titreController.text
                .trim(),

            'preuve':
            cheminPreuve,

            'motif':
            motifController.text
                .trim(),

            'depart':
            typeIndemnite ==
                'Indemnités kilométriques'
                ? departController
                .text
                .trim()
                : null,

            'arivee':
            typeIndemnite ==
                'Indemnités kilométriques'
                ? arriveeController
                .text
                .trim()
                : null,

            'allee_retour':
            typeIndemnite ==
                'Indemnités kilométriques'
                ? allerRetour
                : null,

            'distance_km':
            typeIndemnite ==
                'Indemnités kilométriques'
                ? distanceKm
                : null,
          },
        );

        // ----------------------------------------------------------
        // SUPPRESSION DE L'ANCIENNE PREUVE
        // ----------------------------------------------------------

        if (anciennePreuve !=
            null &&
            anciennePreuve!.isNotEmpty &&
            (preuve != null ||
                supprimerAnciennePreuve)) {
          try {
            await _supabaseService
                .supprimerPreuve(
              anciennePreuve!,
            );
          } catch (_) {
            // La modification DB est déjà faite.
          }
        }
      }

      // ============================================================
      // SUCCES
      // ============================================================

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        SnackBar(
          content: Text(
            widget.modeModification
                ? 'Indemnité modifiée.'
                : 'Indemnité enregistrée.',
          ),
        ),
      );

      Navigator.pop(
        context,
        true,
      );
    } catch (e) {
      // ------------------------------------------------------------
      // Si une nouvelle preuve a été uploadée mais que la suite
      // échoue, on supprime le nouveau fichier.
      // ------------------------------------------------------------

      if (nouvellePreuveChemin !=
          null) {
        try {
          await _supabaseService
              .supprimerPreuve(
            nouvellePreuveChemin,
          );
        } catch (_) {}
      }

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        SnackBar(
          content: Text(
            'Erreur lors de l’enregistrement : $e',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _enregistrementEnCours =
          false;
        });
      }
    }
  }
  Widget _buildChampsMontants() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _champ(
          'Montant HT',
          controller: htController,
          keyboardType: const TextInputType.numberWithOptions(
            decimal: true,
          ),
          validator: _validerMontant,
          onChanged: (_) {
            _calculerTtc();
          },
        ),

        _champ(
          'TVA',
          controller: tvaController,
          keyboardType: const TextInputType.numberWithOptions(
            decimal: true,
          ),
          validator: _validerTva,
          onChanged: (_) {
            _calculerTtc();
          },
        ),

        _champ(
          'Montant TTC',
          controller: ttcController,
          keyboardType: const TextInputType.numberWithOptions(
            decimal: true,
          ),
          readOnly: true,
        ),
      ],
    );
  }
  String? _validerTva(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'La TVA est obligatoire';
    }

    final tva = double.tryParse(
      value.replaceAll(',', '.'),
    );

    if (tva == null) {
      return 'Veuillez saisir une TVA valide';
    }

    if (tva < 0) {
      return 'La TVA ne peut pas être négative';
    }

    return null;
  }
}