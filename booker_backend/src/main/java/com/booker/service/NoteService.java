package com.booker.service;

import com.booker.entity.Note;

import java.util.List;

public interface NoteService {
    List<Note> getNoteList(Long uid, String bookId);

    Note getNote(Long noteId);

    Note add(Long uid, String bookId, Note note);

    Note update(Long noteId, Note note) throws IllegalAccessException;

    void remove(Long noteId);
}
