part of 'repositories.dart';

extension DishRepositoryNotesQuery on DishRepository {
  Future<List<DishNote>> _notesFor(String dishId) async {
    final List<db.DishNoteRow> rows =
        await (_database.select(_database.dishNotes)
              ..where(
                (db.DishNotes table) =>
                    table.dishId.equals(dishId) & table.deletedAt.isNull(),
              )
              ..orderBy(<OrderingTerm Function(db.$DishNotesTable)>[
                (db.DishNotes table) => OrderingTerm.asc(table.position),
                (db.DishNotes table) => OrderingTerm.asc(table.createdAt),
              ]))
            .get();
    return rows.map((db.DishNoteRow row) => row.toDomain()).toList();
  }
}
