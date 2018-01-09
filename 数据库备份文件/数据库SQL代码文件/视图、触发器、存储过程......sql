


--�������ڷ�����Ϣ��ͼ
CREATE VIEW view_overdue(Reader_id,Reader_name,Book_name,Borrow_time,"���ڣ��죩","����(Ԫ)")
AS
SELECT Reader.Reader_id,Reader.Reader_name,Book.Book_name,Borrow.Borrow_time,
	   DATEDIFF(DAY,Borrow.Borrow_time,CONVERT (date,GETDATE(),112))-30 ,
      (DATEDIFF(DAY,Borrow.Borrow_time,CONVERT (date,GETDATE(),112))-30)*0.05 
FROM Reader,Book,Borrow
WHERE Borrow.Book_id=Book.Book_id AND
      Reader.Reader_id=Borrow.Reader_id AND
      DATEDIFF(DAY,Borrow.Borrow_time,CONVERT (date,GETDATE(),112))>30    
      
--����ͼ�����������ͼ
CREATE VIEW view_hotbook(Book_id,Book_name,"��ǰ��������","�������ܴ���")
AS
SELECT Book.Book_id,Book.Book_name,Book.Book_allnum-Book.Book_num,Book_allnum-Book.Book_num+COUNT(History.Book_id)
FROM Book,History
WHERE History.Book_id=Book.Book_id
GROUP BY Book.Book_id,Book_name,Book.Book_allnum-Book.Book_num

      
      
--��ͼ����ϴ������ڡ�ͼ�����͡��е�һ������Ǿۼ������� 
CREATE INDEX BookType ON Book(Book_type);


--����Ȩ��
CREATE LOGIN login2 with password='abcd1234', default_database=Library_342
CREATE USER user2 FOR LOGIN login2 with default_schema=dbo
GRANT INSERT,SELECT,UPDATE,DELETE
ON Borrow
TO user2

 
 --����TR_Book_update_Booknum_allnum�����������޸�ͼ����Ϣʱ,����������Ĺ�ϵ���Ӧ     
CREATE TRIGGER TR_Book_update_Booknum_allnum
ON Book AFTER update
ASIF (SELECT inserted.Book_allnum-inserted.Book_num-count(Borrow.Book_id)FROM Borrow,insertedWHERE Borrow.Book_id=inserted.Book_idGROUP BY Book_allnum,Book_num)!=0BEGIN      PRINT 'ͼ���������������Ӧ! '	     ROLLBACKEND

--����TR_Book_Delete_Borrow_History_Shop����������ɾ��ͼ��ʱ,����ͼ��Ľ�����Ϣɾ��       
CREATE TRIGGER TR_Book_Delete_Borrow_History_Shop
ON Book INSTEAD OF delete
ASBEGIN      DELETE     FROM Borrow     WHERE Borrow.Book_id in (     		SELECT Book_id     		FROM deleted)	 PRINT '��ͼ��Ľ�����Ϣ��ɾ��! '     DELETE     FROM History     WHERE History.Book_id in (     		SELECT Book_id     		FROM deleted)	 PRINT '��ͼ��ı�������ʷ��ɾ��! '     DELETE     FROM Shop     WHERE Shop.Book_id in (     		SELECT Book_id     		FROM deleted)	 PRINT '��ͼ��Ĳɹ���Ϣ��ɾ��! '	 	 	 DELETE     FROM Book     WHERE Book_id in(     		SELECT Book_id     		FROM deleted)    PRINT '��ͼ����ɾ��! '	 END


       
--����TR_Borrow_insert_8_Booknum_exits��������ÿ������ܽ�8����,�ж�ͼ����,�ж��Ƿ��ѽ���飬����ͼ������и���
CREATE TRIGGER TR_Borrow_insert_8_Booknum_exits
ON Borrow AFTER insert
AS
IF (SELECT COUNT(Borrow.Reader_id) FROM Borrow,inserted
WHERE Borrow.Reader_id=inserted.Reader_id)>8
BEGIN      PRINT '���ֻ�ܽ�8����! '	     ROLLBACKEND
else IF (SELECT Book.Book_num FROM Book,inserted
WHERE Book.Book_id=inserted.Book_id)=0
BEGIN      PRINT '��ͼ���治��! '	     ROLLBACKENDelseBEGIN      UPDATE Book     SET Book_num=Book_num-1     WHERE Book_id in (		SELECT Book_id		FROM inserted)	 PRINT 'ͼ�����Ѹ���! 'END--����TR_Borrow_Delete_Booknum����������ɾ�����ļ�¼ʱ,��ͼ������и��²������ļ�¼��¼��������ʷ����     
CREATE TRIGGER TR_Borrow_Delete_Booknum
ON Borrow AFTER delete
ASBEGIN      UPDATE Book     SET Book_num=Book_num+1     WHERE Book_id in (		SELECT Book_id		FROM deleted)	PRINT 'ͼ�����Ѹ���! '	INSERT 	INTO History(Reader_id,Book_id,Borrow_time)	SELECT deleted.Reader_id,deleted.Book_id,deleted.Borrow_time	FROM deletedEND--����TR_History_insert_Return_time��������������ʱ����ʱ�䲻�ܱȽ���ʱ����       
CREATE TRIGGER TR_History_insert_Return_time
ON History AFTER INSERT
ASIF (SELECT DATEDIFF(DAY,inserted.Return_time,inserted.Borrow_time) FROM inserted,HistoryWHERE History.Book_id=inserted.Book_id AND History.Reader_id=inserted.Reader_id) >0BEGIN      PRINT '�黹���ڲ��ܱȽ���������! '	     ROLLBACKEND--����TR_Reader_Delete_Borrow����������ɾ������ʱ,���ö��ߵĽ�����Ϣɾ��       
CREATE TRIGGER TR_Reader_Delete_Borrow
ON Reader  INSTEAD OF  delete
ASBEGIN      DELETE     FROM Borrow     WHERE Borrow.Reader_id in(     		SELECT Reader_id     		FROM deleted)	PRINT '�ö��ߵĽ�����Ϣ��ɾ��! '	DELETE     FROM History     WHERE History.Reader_id in(     		SELECT Reader_id     		FROM deleted)	PRINT '�ö��ߵĽ�����ʷ��ɾ��! '	DELETE    FROM Reader    WHERE Reader_id in(     		SELECT Reader_id     		FROM deleted)    PRINT '�ö�����ɾ��! 'END



--����TR_Shopper_Delete_Shop����������ɾ���ɹ�Աʱ,���òɹ�Ա�Ĳɹ���Ϣɾ��       
CREATE TRIGGER TR_Shopper_Delete_Shop
ON Shopper INSTEAD OF delete
ASBEGIN 
     DELETE     FROM Shop     WHERE Shop.shopper_id in (     		SELECT shopper_id     		FROM deleted)	 PRINT '�òɹ�Ա�Ĳɹ���Ϣ��ɾ��! '	 	 	 DELETE     FROM Shopper     WHERE shopper_id in(     		SELECT shopper_id     		FROM deleted)    PRINT '�òɹ�Ա��ɾ��! '	 END



--�洢���̲�ѯĳ��ͼ�������
CREATE  PROCEDURE  Book_Type_num
  @Book_type NVARCHAR(20)='��Ȼ��ѧ'
AS
 SELECT Book_type, COUNT(Book.Book_id) '�����͵�ͼ������(һ������ֻ��һ��)'
	FROM Book
    WHERE Book.Book_type = @Book_type 
    GROUP BY Book_type
 
    
EXEC Book_Type_num  '��Ȼ��ѧ'


--�洢������Reader�в���һ�����ݣ���������ݾ�ͨ������������
CREATE PROC p_InsertReader
  @Reader_id    CHAR(7)  ,
  @Reader_password  CHAR(8),
  @Reader_name  NCHAR(5) ,
  @Reader_sex   NCHAR(1) , 
  @Reader_age   TINYINT,
  @Reader_Company   NVARCHAR(20),
  @Reader_work  NVARCHAR(20)
AS
 INSERT INTO Reader  
   VALUES(@Reader_id,@Reader_password,@Reader_name,@Reader_sex,@Reader_age,@Reader_Company,@Reader_work)
  
   
exec p_InsertReader 'R061101','123456','����','��',21,'�㶫�ƾ���ѧ','ѧ��'


--��������ͼview_hotbook��������Ĵ洢����
CREATE  PROCEDURE  HOT_BOOK_SORTING
AS
SELECT *
FROM view_hotbook
order by "�������ܴ���" DESC


EXEC HOT_BOOK_SORTING


CREATE  PROCEDURE  BOOK_type_select
AS
DECLARE @Book_id CHAR(8),@Book_name CHAR(15),@Book_writer  CHAR(8),@Book_publisher  CHAR(18),@Book_price char(6),
@Book_introduction CHAR(15),@Book_type CHAR(20),@Book_num char(6),@Book_allnum char(6)
DECLARE C1 CURSOR FOR SELECT DISTINCT Book_type FROM Book 
where Book_type in(select Book_type from Book)
OPEN C1
FETCH NEXT FROM C1 INTO @Book_type
WHILE @@FETCH_STATUS = 0
BEGIN
  PRINT @Book_type 
  PRINT 'Book_id Book_name Book_writer Book_publisher Book_price Book_intro.. Book_num Book_allnum'
  DECLARE C2 CURSOR FOR
  SELECT Book_id,Book_name,Book_writer,Book_publisher,Book_price,Book_introduction,Book_num,Book_allnum FROM Book 
  where Book_type = @Book_type 
OPEN C2
  FETCH NEXT FROM C2 INTO @Book_id,@Book_name,@Book_writer,@Book_publisher,@Book_price,@Book_introduction,@Book_num,@Book_allnum
  WHILE @@FETCH_STATUS = 0
  BEGIN
    PRINT @Book_id + @Book_name + @Book_writer + @Book_publisher + @Book_price + @Book_introduction + @Book_num + @Book_allnum
    FETCH NEXT FROM C2 INTO @Book_id,@Book_name,@Book_writer,@Book_publisher,@Book_price,@Book_introduction,@Book_num,@Book_allnum
  END
  CLOSE C2
  DEALLOCATE C2
  PRINT ''
  FETCH NEXT FROM C1 INTO @Book_type
END
CLOSE C1
DEALLOCATE C1


EXEC BOOK_type_select

--�洢���̲�ѯͼ����
CREATE  PROCEDURE  Book_name_select
  @Book_name NVARCHAR(20)='ͯ��'
AS
 SELECT *
	FROM Book
    WHERE Book.Book_name = @Book_name
 
 EXEC Book_name_select
 
 --�洢���̲�ѯ����
CREATE  PROCEDURE  Book_writer_select
  @Book_writer NCHAR(5)='����'
AS
 SELECT *
	FROM Book
    WHERE Book.Book_writer = @Book_writer
 
 EXEC Book_writer_select