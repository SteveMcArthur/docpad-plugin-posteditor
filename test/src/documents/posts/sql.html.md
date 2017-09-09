---
title: SQL
docId: 1504968258876
author: 
layout: post
editdate: Sat Sep 09 2017 15:44:18 GMT+0100 (GMT Summer Time)
edit_user: 
edit_user_id: undefined
---


Select * from members where user = '*'

Select * from members where email = 'x' AND email IS NULL; --';

SELECT email, passwd, login_id, full_name FROM members WHERE email = 'x'; DROP TABLE members; --'; 