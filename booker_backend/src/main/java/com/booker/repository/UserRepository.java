package com.booker.repository;

import com.booker.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

import java.util.Set;

@Repository
public interface UserRepository extends JpaRepository<User, Long>, JpaSpecificationExecutor<User> {

    @Query("select u from User u where u.account.username = :username")
    User findByUsername(@Param("username") Long username);

    @Query("select u from User u where u.email = :email")
    User findByEmail(@Param("email") String email);

    @Transactional
    @Modifying
    @Query("update Account a set a.password=:password where a.user.uid=:uid")
    void updatePassword(@Param("uid") Long uid, @Param("password") String password);

    @Transactional
    @Modifying
    @Query("update User u\n" +
            "set u.readingPlan = :readingPlan\n" +
            "where u.uid = :uid")
    void updateReadingPlanByUid(@Param("uid") Long uid, @Param("readingPlan") Integer readingPlan);

}
