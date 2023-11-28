package com.booker.repository;

import com.booker.entity.Book;
import com.booker.entity.UserBook;
import com.booker.entity.view.SimpleBookVO;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Repository
public interface UserBookRepository extends JpaRepository<UserBook, Long> {

    @Query("select new com.booker.entity.view.SimpleBookVO(b.author, b.bookId, b.bookName, b.subtitle, b.publishDate, b.publisher, b.coverImgUrl) " +
            "from Book b " +
            "inner join UserBook ub on b.bookId=ub.book.bookId " +
            "where ub.reader.uid = :uid " +
            "and ub.status = :status")
    List<SimpleBookVO> findBookListByUidAndStatus(@Param("uid") Long uid, @Param("status") Integer status);

    @Query("select b\n" +
            "from Book b\n" +
            "inner join UserBook ub on b.bookId=ub.book.bookId\n" +
            "where ub.reader.uid = :uid")
    List<Book> findBookListByUid(@Param("uid") Long uid);

    @Query("select ub from UserBook ub where ub.book.bookId=:bookId and ub.reader.uid=:uid")
    UserBook findOneByBookAndUser(@Param("bookId") String bookId, @Param("uid") Long uid);

    @Transactional
    @Modifying
    @Query(nativeQuery = true,
            value = "insert into user_book(book, reader, status) values(:bookId, :uid, :status)")
    void insertOne(@Param("bookId") String bookId, @Param("uid") Long uid, @Param("status") Integer status);

    @Transactional
    @Modifying
    @Query("delete from UserBook ub where ub.book.bookId=:bookId and ub.reader.uid=:uid")
    void deleteByBookAndUser(@Param("bookId") String bookId, @Param("uid") Long uid);
}
