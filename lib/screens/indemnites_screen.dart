import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/supabase_service.dart';
import 'ajouter_indemnite_screen.dart';

class IndemnitesScreen
    extends StatefulWidget {
  final int idPersonne;
  final String personne;

  const IndemnitesScreen({
    super.key,
    required this.personne,
    required this.idPersonne,
  });

  @override
  State<IndemnitesScreen> createState() =>
      _IndemnitesScreenState();
}

class _IndemnitesScreenState
    extends State<IndemnitesScreen> {
  final SupabaseService _supabaseService =
  SupabaseService();

  late Future<
      List<Map<String, dynamic>>
  > _indemnitesFuture;

  // ================================================================
  // INIT
  // ================================================================

  @override
  void initState() {
    super.initState();

    _chargerIndemnites();
  }

  void _chargerIndemnites() {
    _indemnitesFuture =
        _supabaseService.getIndemnites(
          widget.idPersonne,
        );
  }

  // ================================================================
  // ACTUALISER
  // ================================================================

  Future<void> _actualiser() async {
    setState(() {
      _chargerIndemnites();
    });

    await _indemnitesFuture;
  }

  // ================================================================
  // MODIFIER
  // ================================================================

  Future<void> _modifierIndemnite(
      Map<String, dynamic> indemnite,
      ) async {
    final resultat =
    await Navigator.push(
      context,

      MaterialPageRoute(
        builder: (context) =>
            AjouterIndemniteScreen(
              idPersonne:
              widget.idPersonne,

              indemniteExistante:
              indemnite,
            ),
      ),
    );

    if (resultat == true &&
        mounted) {
      setState(() {
        _chargerIndemnites();
      });
    }
  }

  // ================================================================
  // OUVRIR PREUVE
  // ================================================================

  Future<void> _ouvrirPreuve(
      String chemin,
      ) async {
    try {
      final url =
      _supabaseService
          .getUrlPreuve(
        chemin,
      );

      final uri =
      Uri.parse(url);

      final ouvert =
      await launchUrl(
        uri,
        mode:
        LaunchMode.externalApplication,
      );

      if (!ouvert) {
        throw Exception(
          'Impossible d’ouvrir le fichier.',
        );
      }
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        SnackBar(
          content: Text(
            'Impossible d’ouvrir la preuve : $e',
          ),
        ),
      );
    }
  }

  // ================================================================
  // SUPPRIMER
  // ================================================================

  Future<void> _supprimerIndemnite(
      int idIndemnisation,
      ) async {
    final confirmation =
    await showDialog<bool>(
      context: context,

      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Supprimer l’indemnité ?',
          ),

          content: const Text(
            'Cette action supprimera également la preuve associée.',
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  false,
                );
              },

              child:
              const Text(
                'Annuler',
              ),
            ),

            FilledButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  true,
                );
              },

              child:
              const Text(
                'Supprimer',
              ),
            ),
          ],
        );
      },
    );

    if (confirmation != true) {
      return;
    }

    try {
      await _supabaseService
          .supprimerIndemniteAvecPreuve(
        idIndemnisation,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _chargerIndemnites();
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        const SnackBar(
          content: Text(
            'Indemnité supprimée.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        SnackBar(
          content: Text(
            'Erreur lors de la suppression : $e',
          ),
        ),
      );
    }
  }

  // ================================================================
  // BUILD
  // ================================================================

  @override
  Widget build(
      BuildContext context,
      ) {
    return Scaffold(
      backgroundColor:
      const Color(0xFFF5F9FC),

      appBar: AppBar(
        backgroundColor:
        const Color(0xFFF5F9FC),

        elevation: 0,

        title: Text(
          'Indemnités de ${widget.personne}',

          style:
          const TextStyle(
            fontWeight:
            FontWeight.bold,
          ),
        ),
      ),

      body: Padding(
        padding:
        const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,

          children: [
            const Text(
              'Mes indemnités',

              style: TextStyle(
                fontSize: 24,
                fontWeight:
                FontWeight.bold,
              ),
            ),

            const SizedBox(
              height: 20,
            ),

            Expanded(
              child: FutureBuilder<
                  List<
                      Map<String,
                          dynamic>>>(
                future:
                _indemnitesFuture,

                builder:
                    (context, snapshot) {
                  if (snapshot
                      .connectionState ==
                      ConnectionState
                          .waiting) {
                    return const Center(
                      child:
                      CircularProgressIndicator(),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisSize:
                        MainAxisSize.min,

                        children: [
                          const Icon(
                            Icons
                                .error_outline,
                            size: 50,
                          ),

                          const SizedBox(
                            height: 15,
                          ),

                          const Text(
                            'Impossible de récupérer les indemnités.',
                            textAlign:
                            TextAlign
                                .center,
                          ),

                          const SizedBox(
                            height: 20,
                          ),

                          ElevatedButton(
                            onPressed:
                            _actualiser,

                            child:
                            const Text(
                              'Réessayer',
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  final indemnites =
                      snapshot.data ??
                          [];

                  if (indemnites.isEmpty) {
                    return RefreshIndicator(
                      onRefresh:
                      _actualiser,

                      child:
                      ListView(
                        physics:
                        const AlwaysScrollableScrollPhysics(),

                        children: const [
                          SizedBox(
                            height: 100,
                          ),

                          Center(
                            child: Text(
                              'Aucune indemnité.',
                              style:
                              TextStyle(
                                fontSize:
                                16,
                                color:
                                Colors.grey,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh:
                    _actualiser,

                    child:
                    ListView.builder(
                      physics:
                      const AlwaysScrollableScrollPhysics(),

                      itemCount:
                      indemnites.length,

                      itemBuilder:
                          (context, index) {
                        final indemnite =
                        indemnites[
                        index];

                        final preuve =
                        indemnite[
                        'preuve'];

                        return _IndemniteCard(
                          idIndemnisation:
                          (indemnite[
                          'id_indemnisation']
                          as num)
                              .toInt(),

                          type: _nomType(
                            indemnite[
                            'id_type'],
                          ),

                          montant:
                          _formaterMontant(
                            indemnite[
                            'montant_calculer'] ??
                                indemnite[
                                'montant_saisie'],
                          ),

                          date:
                          _formaterDate(
                            indemnite[
                            'date_indemnisation'],
                          ),

                          hasPreuve:
                          preuve !=
                              null &&
                              preuve
                                  .toString()
                                  .isNotEmpty,

                          onModifier: () {
                            _modifierIndemnite(
                              indemnite,
                            );
                          },

                          onPreuve:
                          preuve == null
                              ? null
                              : () {
                            _ouvrirPreuve(
                              preuve
                                  .toString(),
                            );
                          },

                          onSupprimer: () {
                            _supprimerIndemnite(
                              (indemnite[
                              'id_indemnisation']
                              as num)
                                  .toInt(),
                            );
                          },
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),

      floatingActionButton:
      FloatingActionButton(
        onPressed: () async {
          final resultat =
          await Navigator.push(
            context,

            MaterialPageRoute(
              builder: (context) =>
                  AjouterIndemniteScreen(
                    idPersonne:
                    widget.idPersonne,
                  ),
            ),
          );

          if (resultat == true &&
              mounted) {
            setState(() {
              _chargerIndemnites();
            });
          }
        },

        child:
        const Icon(Icons.add),
      ),
    );
  }

  // ================================================================
  // NOM TYPE
  // ================================================================

  String _nomType(
      dynamic idType,
      ) {
    switch (idType) {
      case 1:
        return 'Restauration';

      case 2:
        return 'Kilométrique';

      case 3:
        return 'Autre';

      case 4:
        return 'Péage / Parking';

      default:
        return 'Autre';
    }
  }

  // ================================================================
  // MONTANT
  // ================================================================

  String _formaterMontant(
      dynamic montant,
      ) {
    if (montant == null) {
      return '-';
    }

    final valeur =
    double.tryParse(
      montant
          .toString()
          .replaceAll(
        ',',
        '.',
      ),
    );

    if (valeur == null) {
      return '$montant €';
    }

    return '${valeur.toStringAsFixed(2).replaceAll('.', ',')} €';
  }

  // ================================================================
  // DATE
  // ================================================================

  String _formaterDate(
      dynamic date,
      ) {
    if (date == null) {
      return '-';
    }

    final texte =
    date.toString();

    final partieDate =
        texte.split('T').first;

    final morceaux =
    partieDate.split('-');

    if (morceaux.length == 3) {
      return '${morceaux[2]}/${morceaux[1]}/${morceaux[0]}';
    }

    return partieDate;
  }
}

// ==================================================================
// CARTE INDEMNITE
// ==================================================================

class _IndemniteCard
    extends StatelessWidget {
  final int idIndemnisation;

  final String type;
  final String montant;
  final String date;

  final bool hasPreuve;

  final VoidCallback onModifier;

  final VoidCallback? onPreuve;

  final VoidCallback onSupprimer;

  const _IndemniteCard({
    required this.idIndemnisation,
    required this.type,
    required this.montant,
    required this.date,
    required this.hasPreuve,
    required this.onModifier,
    required this.onPreuve,
    required this.onSupprimer,
  });

  // ================================================================
  // ICONE
  // ================================================================

  IconData _iconeSelonType() {
    final typeNormalise =
    type.toLowerCase().trim();

    if (typeNormalise
        .contains('kilométrique') ||
        typeNormalise
            .contains('kilometrique')) {
      return Icons.directions_car;
    }

    if (typeNormalise
        .contains('restauration') ||
        typeNormalise
            .contains('restaurant')) {
      return Icons.restaurant;
    }

    if (typeNormalise
        .contains('péage') ||
        typeNormalise
            .contains('parking')) {
      return Icons.local_parking;
    }

    return Icons.receipt_long;
  }

  // ================================================================
  // COULEUR FOND
  // ================================================================

  Color _couleurSelonType() {
    final typeNormalise =
    type.toLowerCase().trim();

    if (typeNormalise
        .contains('kilométrique') ||
        typeNormalise
            .contains('kilometrique')) {
      return const Color(
        0xFFD9E8FF,
      );
    }

    if (typeNormalise
        .contains('restauration') ||
        typeNormalise
            .contains('restaurant')) {
      return const Color(
        0xFFDFF3D8,
      );
    }

    if (typeNormalise
        .contains('péage') ||
        typeNormalise
            .contains('parking')) {
      return const Color(
        0xFFFFE5C2,
      );
    }

    return const Color(
      0xFFE5E5E5,
    );
  }

  // ================================================================
  // COULEUR ICONE
  // ================================================================

  Color _couleurIcone() {
    final typeNormalise =
    type.toLowerCase().trim();

    if (typeNormalise
        .contains('kilométrique') ||
        typeNormalise
            .contains('kilometrique')) {
      return const Color(
        0xFF2874D0,
      );
    }

    if (typeNormalise
        .contains('restauration') ||
        typeNormalise
            .contains('restaurant')) {
      return const Color(
        0xFF5C8F20,
      );
    }

    if (typeNormalise
        .contains('péage') ||
        typeNormalise
            .contains('parking')) {
      return const Color(
        0xFFD98200,
      );
    }

    return Colors.grey;
  }

  // ================================================================
  // BUILD
  // ================================================================

  @override
  Widget build(
      BuildContext context,
      ) {
    return Card(
      margin:
      const EdgeInsets.only(
        bottom: 12,
      ),

      child: Padding(
        padding:
        const EdgeInsets.all(16),

        child: Row(
          children: [
            // --------------------------------------------------------
            // ICONE
            // --------------------------------------------------------

            Container(
              width: 58,
              height: 58,

              decoration:
              BoxDecoration(
                color:
                _couleurSelonType(),

                shape:
                BoxShape.circle,
              ),

              child: Icon(
                _iconeSelonType(),

                size: 30,

                color:
                _couleurIcone(),
              ),
            ),

            const SizedBox(
              width: 15,
            ),

            // --------------------------------------------------------
            // TYPE + DATE
            // --------------------------------------------------------

            Expanded(
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment
                    .start,

                children: [
                  Text(
                    type,

                    style:
                    const TextStyle(
                      fontSize: 16,
                      fontWeight:
                      FontWeight.bold,
                    ),
                  ),

                  const SizedBox(
                    height: 8,
                  ),

                  Row(
                    children: [
                      const Icon(
                        Icons
                            .calendar_today,
                        size: 16,
                        color:
                        Colors.grey,
                      ),

                      const SizedBox(
                        width: 6,
                      ),

                      Text(
                        date,

                        style:
                        const TextStyle(
                          color:
                          Colors.grey,
                        ),
                      ),
                    ],
                  ),

                  if (hasPreuve)
                    Padding(
                      padding:
                      const EdgeInsets
                          .only(
                        top: 6,
                      ),

                      child: Row(
                        children: [
                          const Icon(
                            Icons
                                .attach_file,
                            size: 15,
                          ),

                          const SizedBox(
                            width: 4,
                          ),

                          GestureDetector(
                            onTap:
                            onPreuve,

                            child:
                            const Text(
                              'Voir la preuve',
                              style:
                              TextStyle(
                                decoration:
                                TextDecoration
                                    .underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),

            // --------------------------------------------------------
            // MONTANT + ACTIONS
            // --------------------------------------------------------

            Column(
              crossAxisAlignment:
              CrossAxisAlignment
                  .end,

              children: [
                Text(
                  montant,

                  style:
                  const TextStyle(
                    fontSize: 17,
                    fontWeight:
                    FontWeight.bold,
                  ),
                ),

                const SizedBox(
                  height: 8,
                ),

                Row(
                  mainAxisSize:
                  MainAxisSize.min,

                  children: [
                    IconButton(
                      onPressed:
                      onModifier,

                      icon:
                      const Icon(
                        Icons.edit,
                        color:
                        Colors.blue,
                      ),

                      tooltip:
                      'Modifier',
                    ),

                    IconButton(
                      onPressed:
                      onSupprimer,

                      icon:
                      const Icon(
                        Icons.delete,
                        color:
                        Colors.red,
                      ),

                      tooltip:
                      'Supprimer',
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}