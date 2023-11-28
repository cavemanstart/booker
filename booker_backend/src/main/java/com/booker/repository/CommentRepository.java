package com.booker.repository;

import com.booker.entity.Comment;
import com.booker.entity.view.CommentVO;
import com.booker.entity.view.RatingStatistics;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;
import java.util.Optional;

@Repository
public interface CommentRepository extends JpaRepository<Comment, Long>, JpaSpecificationExecutor<Comment> {

    @Query(nativeQuery = true,
            value = "select c.comment_id commentId, likes, c.comment_time commentTime, rating, content, username, nickname, sex, ui.head_url headUrl\n" +
                    "from comment c\n" +
                    "inner join book b on b.book_id = c.book\n" +
                    "inner join user_info ui on ui.uid = c.uid\n" +
                    "inner join account a on ui.uid = a.uid\n" +
                    "where b.book_id = :bookId")
    List<Map<String, Object>> findAllVOByBookId(@Param("bookId") String bookId);

    @Query(nativeQuery = true,
            value = "select c.comment_id commentId, likes, c.comment_time commentTime, rating, content, username, nickname, sex, ui.head_url headUrl\n" +
                    "from comment c\n" +
                    "inner join book b on b.book_id = c.book\n" +
                    "inner join user_info ui on ui.uid = c.uid\n" +
                    "inner join account a on ui.uid = a.uid\n" +
                    "where b.book_id = :bookId\n" +
                    "limit :limit")
    List<Map<String, Object>> findLimitByBookId(@Param("bookId") String bookId, @Param("limit") int limit);


    @Query("select new com.booker.entity.view.RatingStatistics(avg(c.rating), count(c))\n" +
            "from Comment c\n" +
            "where c.bookId = :bookId")
    RatingStatistics getRatingBaseInfo(@Param("bookId") String bookId);

    @Query("select count(c)\n" +
            "from Comment c\n" +
            "where c.bookId = :bookId\n" +
            "and c.rating>:start and c.rating<=:end")
    Long getSumOfRatingBetween(@Param("bookId") String bookId, @Param("start") Double start, @Param("end") Double end);

    @Query(nativeQuery = true,
            value = "select c.comment_id commentId, likes, c.comment_time commentTime, rating, content, username, nickname, sex, ui.head_url headUrl " +
                    "from comment c " +
                    "inner join book b on b.book_id = c.book " +
                    "inner join user_info ui on ui.uid = c.uid " +
                    "inner join account a on ui.uid = a.uid " +
                    "where b.book_id = :bookId " +
                    "and ui.uid = :uid")
    CommentVO findOneByBookAndUser(@Param("bookId") String bookId, @Param("uid") Long uid);

    @Query(nativeQuery = true,
            value = "select c.comment_id commentId, likes, c.comment_time commentTime, rating, content, username, nickname, sex, ui.head_url headUrl " +
                    "from comment c " +
                    "inner join book b on b.book_id = c.book " +
                    "inner join user_info ui on ui.uid = c.uid " +
                    "inner join account a on ui.uid = a.uid " +
                    "where c.comment_id = :commentId")
    CommentVO findOneById(@Param("commentId") Long commentId);

    @Transactional
    @Modifying
    @Query(nativeQuery = true,
            value = "insert into user_like_comment(comment_id, uid) values(:commentId, :uid)")
    void insertLikeByCommentIdAndUid(@Param("commentId") Long commentId, @Param("uid") Long uid);

    @Transactional
    @Modifying
    @Query(nativeQuery = true,
            value = "delete from user_like_comment where comment_id=:commentId and uid=:uid")
    void deleteLikeByCommentIdAndUid(@Param("commentId") Long commentId, @Param("uid") Long uid);

    @Query(nativeQuery = true,
            value = "select count(1)\n" +
                    "from comment c\n" +
                    "where comment_time between :startTime and :endTime\n" +
                    "and uid = :uid")
    Integer getReadNum(@Param("uid") Long uid, @Param("startTime") LocalDate startTime, @Param("endTime") LocalDate endTime);

    @Transactional
    @Modifying
    @Query("delete from Comment c where c.book.bookId=:bookId and c.user.uid=:uid")
    void deleteAllByBookAndUser(@Param("bookId") String bookId, @Param("uid") Long uid);

    @Query(nativeQuery = true,
            value = "select count(1)>0 " +
                    "from user_like_comment " +
                    "where uid = :uid " +
                    "and comment_id = :commentId")
    boolean checkLikeByCommentIdAndUid(@Param("commentId") Long commentId, @Param("uid") Long uid);

    Optional<Comment> findByBookIdAndUid(@Param("bookId") String bookId, @Param("uid") Long uid);

    @Query(nativeQuery = true,
            value = "select count(1) > 0\n" +
                    "from user_like_comment ulc\n" +
                    "where comment_id = :commentId\n" +
                    "and uid = :uid")
    Boolean hasUserLiked(@Param("commentId") Long commentId, @Param("uid") Long uid);
}
