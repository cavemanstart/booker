package com.booker.repository;

import com.booker.entity.Note;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface NoteRepository extends JpaRepository<Note, Long> {
    @Query("select n " +
            "from Note n " +
            "inner join UserBook ub " +
            "on n.userBook.userBookId = ub.userBookId " +
            "where ub.reader.uid=:uid " +
            "and ub.book.bookId=:bookId")
    List<Note> findAllByUserAndBook(@Param("uid") Long uid, @Param("bookId") String bookId);
}
