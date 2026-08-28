import 'package:flutter/material.dart';

import '../services/supabase_service.dart';
import 'indemnites_screen.dart';

class SelectionPersonneScreen extends StatefulWidget {
  const SelectionPersonneScreen({super.key});

  @override
  State<SelectionPersonneScreen> createState() =>
      _SelectionPersonneScreenState();
}

class _SelectionPersonneScreenState
    extends State<SelectionPersonneScreen> {
  final SupabaseService _supabaseService = SupabaseService();

  late Future<List<Map<String, dynamic>>> _personnesFuture;

  @override
  void initState() {
    super.initState();

    _personnesFuture = _supabaseService.getPersonnes();
  }

  Future<void> _actualiser() async {
    setState(() {
      _personnesFuture = _supabaseService.getPersonnes();
    });
  }

  Color _couleurPersonne(int index) {
    const couleurs = [
      Color(0xFFFFE4C2),
      Color(0xFFE4D9FF),
      Color(0xFFD9F7ED),
      Color(0xFFD9EAF7),
      Color(0xFFFFD9D9),
    ];

    return couleurs[index % couleurs.length];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F9FC),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),

          child: Column(
            children: [
              const SizedBox(height: 80),

              const Text(
                'Qui êtes-vous ?',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 40),

              Expanded(
                child: FutureBuilder<List<Map<String, dynamic>>>(
                  future: _personnesFuture,

                  builder: (context, snapshot) {
                    // ------------------------------------------------
                    // CHARGEMENT
                    // ------------------------------------------------

                    if (snapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    // ------------------------------------------------
                    // ERREUR
                    // ------------------------------------------------

                    if (snapshot.hasError) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              size: 50,
                            ),

                            const SizedBox(height: 15),

                            const Text(
                              'Impossible de récupérer les personnes.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                              ),
                            ),

                            const SizedBox(height: 10),

                            Text(
                              snapshot.error.toString(),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),

                            const SizedBox(height: 20),

                            ElevatedButton(
                              onPressed: _actualiser,
                              child: const Text('Réessayer'),
                            ),
                          ],
                        ),
                      );
                    }

                    // ------------------------------------------------
                    // AUCUNE PERSONNE
                    // ------------------------------------------------

                    final personnes = snapshot.data ?? [];

                    if (personnes.isEmpty) {
                      return const Center(
                        child: Text(
                          'Aucune personne trouvée.',
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      );
                    }

                    // ------------------------------------------------
                    // LISTE DES PERSONNES
                    // ------------------------------------------------

                    return RefreshIndicator(
                      onRefresh: _actualiser,

                      child: ListView.separated(
                        physics:
                        const AlwaysScrollableScrollPhysics(),

                        itemCount: personnes.length,

                        separatorBuilder: (context, index) {
                          return const SizedBox(height: 25);
                        },

                        itemBuilder: (context, index) {
                          final personne = personnes[index];

                          final int idPersonne =
                          personne['id_personne'] as int;

                          final String prenom =
                              personne['prenom']?.toString() ?? '';

                          final String nom =
                              personne['nom']?.toString() ?? '';

                          final String nomAffiche =
                          prenom.isNotEmpty
                              ? prenom
                              : nom;

                          return _PersonneButton(
                            nom: nomAffiche,
                            couleur: _couleurPersonne(index),

                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => IndemnitesScreen(
                                    personne: nomAffiche,
                                    idPersonne: idPersonne,
                                  ),
                                ),
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
      ),
    );
  }
}

// ================================================================
// BOUTON PERSONNE
// ================================================================

class _PersonneButton extends StatelessWidget {
  final String nom;
  final Color couleur;
  final VoidCallback onPressed;

  const _PersonneButton({
    required this.nom,
    required this.couleur,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 180,
        height: 50,

        child: ElevatedButton(
          onPressed: onPressed,

          style: ElevatedButton.styleFrom(
            backgroundColor: couleur,
            foregroundColor: Colors.black,

            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),

          child: Text(
            nom,

            style: const TextStyle(
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}