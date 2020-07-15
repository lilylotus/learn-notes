1. 主键约束（Primay Key Coustraint） 唯一性，非空性
ALTER TABLE 表名 ADD CONSTRAINT 约束名称 PRIMARY KEY(约束表的字段)
2. 唯一约束 （Unique Counstraint）唯一性，空值不受到约束
ALTER TABLE 表名 ADD CONSTRAINT 约束名称 UNIQUE(约束表的字段)
3. 检查约束 (Check Counstraint) 对该列数据的范围、格式的限制（如：年龄、性别等）
ALTER TABLE 表名 ADD CONSTRAINT 约束名称 CHECK (STUAGE BETWEEN 15 AND 40)
ALTER TABLE 表名 ADD CONSTRAINT 约束名称 CHECK (STUSEX=’男’ OR STUSEX=’女′)
4. 默认约束 (Default Counstraint) 该数据的默认值
ALTER TABLE 表名 ADD CONSTRAINT 约束名称 DEFAULT (‘地址不详’) FOR 约束表的字段
5. 外键约束 (Foreign Key Counstraint) 需要建立两表间的关系并引用主表的列
alter table 表名 add constraint 约束名称
    foreign key(约束表的字段) references 关联表名(关联约束表的字段)

--------------------------------------
数据的级联操作：
1. 级联删除：ON DELETE CASCADE, 当主表的数据删除后，相应的子表的数据也会被删除(清理干净)
    CONSTRAINT FK_AID FOREIGN KEY(aid) REFERENCES A(aid) ON DELETE CASCADE
2. 级联更新：ON DELETE SET NULL, 当主表的数据删除后，相应的子表的数据字段的内容会设置为空

==============================================================
约束也是一个对象，若没有自动分配约束名称，系统会自动的生成
非空约束 NOT NULL NK
唯一约束 UNIQUE UK 表的数据列是不能够有重复, 不会受到 NULL 约束 CONSTRAINT uk_name UNIQUE(name)
主键约束 PRIMARY KEY PK 非空+唯一约束 CONSTRAINT pk_id PRIMARY KEY(id)
        CONSTRAINT pk_id_name PRIMARY KEY(id, name) 复合主键，仅当id和name都相同时才报错
检查约束 CHECK KEY CK 对数据字段进行条件过滤 (不建议使用)
主-外键约束 FOREIGN KEY FK 一对多关系,外键必须在主表总为主键或者唯一约束
    CONSTRAINT fk_mid FOREIGN KEY(mid) REFERENCES CT_MEMBER(mid) [ON DELETE CASCADE | ON DELETE SET NULL]
注意：
    对于外键： 要想删除主表中的记录，无法删除(违反了完整性约束)
            若非要删除，先删除子表记录再删除父表记录(但是这样的做法不合适,主表记录被控制的狠)
            级联删除操作： 当主表数据被删除，对应的子表数据也应该同时被清理 (ON DELETE CASCADE)
            级联更新操作: 当主表数据被删除，对应的子表数据字段会被设置为 NULL (ON DELETE SET NULL)
    强制性删除，不管也约束 ： DROP TABLE 表名称 CASCADE CONSTRAINT ; (不建议使用)

查看约束：
    user_constraints
修改约束： (最好不要修改)
    添加约束: ALTER TABLE 表名称 ADD CONSTRAINT 约束名称 约束类型(约束字段) ;
    启用 / 禁用约束: ALTER TABLE 表名称 DISABLE[DISABLE] CONSTRAINT 约束名称[CASCADE] ;
    删除约束: ALTER TABLE 表名称 DROP CONSTRAINT 约束名称 [CASCADE] ;
--ORA-01400: 无法将 NULL 插入
--ORA-00001: 违反唯一约束条件
--ORA-02290: 违反检查约束条件
--ORA-02291: 违反完整约束条件