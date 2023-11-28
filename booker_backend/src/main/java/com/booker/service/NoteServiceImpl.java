package com.booker.service;

import com.booker.entity.Note;
import com.booker.entity.User;
import com.booker.entity.UserBook;
import com.booker.repository.NoteRepository;
import com.booker.repository.UserBookRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.EmptyResultDataAccessException;
import org.springframework.stereotype.Service;

import java.lang.reflect.Field;
import java.util.List;
import java.util.Optional;

@Service
public class NoteServiceImpl implements NoteService {

    @Autowired
    private NoteRepository noteRepository;

    @Autowired
    private UserBookRepository userBookRepository;

    @Override
    public List<Note> getNoteList(Long uid, String bookId) {
        return noteRepository.findAllByUserAndBook(uid, bookId);
    }

    @Override
    public Note getNote(Long noteId) {
        Note note = null;
        Optional<Note> result = noteRepository.findById(noteId);
        if (result.isPresent()) {
            note = result.get();
        }
        return note;
    }

    @Override
    public Note add(Long uid, String bookId, Note note) {
        UserBook userBook = userBookRepository.findOneByBookAndUser(bookId, uid);
        note.setUserBook(userBook);
        Note newNote = noteRepository.saveAndFlush(note);
        Optional<Note> result = noteRepository.findById(newNote.getNoteId());
        return result.orElse(newNote);
    }

    @Override
    public Note update(Long noteId, Note note) throws IllegalAccessException {
        Note oldNote = getNote(noteId);
        for (Field field : Note.class.getDeclaredFields()) {
            field.setAccessible(true);
            Object value = field.get(note);
            if (value != null) {
                field.set(oldNote, value);
            }
        }
        Note newNote = noteRepository.saveAndFlush(oldNote);
        Optional<Note> result = noteRepository.findById(newNote.getNoteId());
        return result.orElse(newNote);
    }

    @Override
    public void remove(Long noteId) {
        try {
            noteRepository.deleteById(noteId);
        } catch (EmptyResultDataAccessException e) {
            e.printStackTrace();
        }
    }
}
