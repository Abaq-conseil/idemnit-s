import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/indemnite.dart';

class SupabaseService {
  final SupabaseClient _client =
      Supabase.instance.client;

  // ================================================================
  // PERSONNES
  // ================================================================

  Future<List<Map<String, dynamic>>> getPersonnes() async {
    final response = await _client
        .from('personnes')
        .select()
        .order('nom');

    return List<Map<String, dynamic>>.from(response);
  }

  Future<Map<String, dynamic>?> getPersonne(
      int idPersonne,
      ) async {
    final response = await _client
        .from('personnes')
        .select()
        .eq('id_personne', idPersonne)
        .maybeSingle();

    return response;
  }

  // ================================================================
  // INDEMNITES - READ
  // ================================================================

  Future<List<Map<String, dynamic>>> getIndemnites(
      int idPersonne,
      ) async {
    final response = await _client
        .from('indemnisation')
        .select()
        .eq('id_personne', idPersonne)
        .order(
      'date_indemnisation',
      ascending: false,
    );

    return List<Map<String, dynamic>>.from(response);
  }

  // ================================================================
  // INDEMNITE - READ ONE
  // ================================================================

  Future<Map<String, dynamic>?> getIndemnite(
      int idIndemnisation,
      ) async {
    final response = await _client
        .from('indemnisation')
        .select()
        .eq(
      'id_indemnisation',
      idIndemnisation,
    )
        .maybeSingle();

    return response;
  }

  // ================================================================
  // INDEMNITES - CREATE
  // ================================================================

  Future<void> ajouterIndemnite(
      Indemnite indemnite,
      ) async {
    await _client
        .from('indemnisation')
        .insert(indemnite.toMap());
  }

  // ================================================================
  // INDEMNITES - UPDATE
  // ================================================================

  Future<void> modifierIndemnite(
      int idIndemnisation,
      Map<String, dynamic> donnees,
      ) async {
    await _client
        .from('indemnisation')
        .update(donnees)
        .eq(
      'id_indemnisation',
      idIndemnisation,
    );
  }

  // ================================================================
  // INDEMNITES - DELETE
  // ================================================================

  Future<void> supprimerIndemnite(
      int idIndemnisation,
      ) async {
    await _client
        .from('indemnisation')
        .delete()
        .eq(
      'id_indemnisation',
      idIndemnisation,
    );
  }

  // ================================================================
  // INDEMNITE + PREUVE - DELETE
  // ================================================================

  Future<void> supprimerIndemniteAvecPreuve(
      int idIndemnisation,
      ) async {
    final indemnite =
    await getIndemnite(idIndemnisation);

    final preuve =
    indemnite?['preuve']?.toString();

    await supprimerIndemnite(
      idIndemnisation,
    );

    if (preuve != null &&
        preuve.isNotEmpty) {
      try {
        await supprimerPreuve(preuve);
      } catch (_) {
        // L'indemnité est déjà supprimée.
      }
    }
  }

  // ================================================================
  // TARIF KILOMETRIQUE
  // ================================================================

  Future<Map<String, dynamic>?> getTarifKilometrique(
      int puissanceFiscale,
      ) async {
    final response = await _client
        .from('tarifs_kilometrique')
        .select()
        .eq(
      'puissance_fiscale',
      puissanceFiscale,
    )
        .limit(1);

    if (response.isEmpty) {
      return null;
    }

    return Map<String, dynamic>.from(
      response.first,
    );
  }

  // ================================================================
  // PREUVE - UPLOAD
  // ================================================================

  Future<String> envoyerPreuve({
    required Uint8List bytes,
    required String nomFichier,
    required int idPersonne,
  }) async {
    final extension =
    nomFichier.contains('.')
        ? nomFichier
        .split('.')
        .last
        .toLowerCase()
        : '';

    final nomUnique =
        '${DateTime.now().millisecondsSinceEpoch}'
        '${extension.isNotEmpty ? '.$extension' : ''}';

    final chemin =
        '$idPersonne/$nomUnique';

    await _client.storage
        .from('preuves')
        .uploadBinary(
      chemin,
      bytes,
      fileOptions: const FileOptions(
        upsert: false,
      ),
    );

    return chemin;
  }

  // ================================================================
  // PREUVE - DELETE
  // ================================================================

  Future<void> supprimerPreuve(
      String chemin,
      ) async {
    await _client.storage
        .from('preuves')
        .remove([chemin]);
  }

  // ================================================================
  // PREUVE - URL
  // ================================================================

  String getUrlPreuve(
      String chemin,
      ) {
    return _client.storage
        .from('preuves')
        .getPublicUrl(chemin);
  }
}