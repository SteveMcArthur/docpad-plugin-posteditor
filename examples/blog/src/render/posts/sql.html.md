---
title: SQL
layout: post
---

Select * from members where user = '*'

Select * from members where email = 'x' AND email IS NULL; --';

SELECT email, passwd, login_id, full_name FROM members WHERE email = 'x'; DROP TABLE members; --'; 