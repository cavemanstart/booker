package com.booker.repository;

import com.booker.entity.Book;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

import java.util.Set;

@Repository
public interface BookRepository extends JpaRepository<Book, String> {
    @Query("select b.tags " +
            "from Book b " +
            "where b.bookId = :bookId")
    Set<String> findTagsByBookId(@Param("bookId") String bookId);

    @Transactional
    @Modifying
    @Query("update Book b " +
            "set b.tags = :tags " +
            "where b.bookId = :bookId")
    void updateTagsById(@Param("bookId") String bookId, @Param("tags") String[] tags);

    Page<Book> findAll(Specification<Book> bookSpecification, Pageable pageable);
}
