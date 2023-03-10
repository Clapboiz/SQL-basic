CREATE DATABASE Tuan_1
USE Tuan_1

CREATE TABLE KHACHHANG (
	MAKH CHAR(4) PRIMARY KEY,
	HOTEN VARCHAR(40),
	DCHI VARCHAR(50),
	SODT VARCHAR(20),
	NGSINH SMALLDATETIME,
	DOANHSO MONEY,
	NGDK SMALLDATETIME
)
GO
-- XOA TABLE
--DROP TABLE dbo.KHACHHANG

CREATE TABLE HOADON (
	SOHD INT PRIMARY KEY,
	NGHD SMALLDATETIME,
	MAKH CHAR(4),
	MANV CHAR(4),
	TRIGIA MONEY
)
GO

CREATE TABLE NHANVIEN(
	MANV CHAR(4) PRIMARY KEY,
	HOTEN VARCHAR(40),
	SODT VARCHAR(20),
	NGVL SMALLDATETIME
)
GO

CREATE TABLE SANPHAM(
	MASP CHAR(4) PRIMARY KEY,
	TENSP VARCHAR(40),
	DVT VARCHAR(20),
	NUOCSX VARCHAR(40),
	GIA MONEY
)
GO

CREATE TABLE CTHD (
	SOHD INT,
	MASP CHAR(4),
	SL INT,
	PRIMARY KEY(SOHD,MASP)
)
GO 

--TAO KHOA NGOAI
--FK_HOADON VA KHACHHANG

ALTER TABLE dbo.HOADON
ADD CONSTRAINT FK_HD_KH FOREIGN KEY (MAKH) REFERENCES dbo.KHACHHANG (MAKH)


--TAO KHOA NGOAI
--FK_HOADON VA NHANVIEN
ALTER TABLE dbo.HOADON
ADD CONSTRAINT FK_HD_NV FOREIGN KEY (MANV) REFERENCES dbo.NHANVIEN (MANV)


--TAO KHOA NGOAI
--FK_CTHD VA HOADON
ALTER TABLE dbo.CTHD
ADD CONSTRAINT FK_CTHD_HD FOREIGN KEY (SOHD) REFERENCES dbo.HOADON (SOHD)


--TAO KHOA NGOAI
--FK_CTHD VA SANPHAM
ALTER TABLE dbo.CTHD
ADD CONSTRAINT FK_CTHD_SP FOREIGN KEY (MASP) REFERENCES dbo.SANPHAM (MASP)


--THEM THUOC TINH GHICHU CHO SANPHAM
ALTER TABLE dbo.SANPHAM
ADD GHICHU VARCHAR(20)

--THEM THUOC TINH LOAIKH CHO KHACHHANG
ALTER TABLE dbo.KHACHHANG
ADD LOAIKH TINYINT

--SUA KIEU DU LIEU GHICHU TRONG QUAN HE SANPHAM
ALTER TABLE dbo.SANPHAM
ALTER COLUMN GHICHU VARCHAR(100)

--XOA THUOC TINH GHI CHU TRONG QUANHE SANPHAM
ALTER TABLE dbo.SANPHAM
DROP COLUMN GHICHU

--6 Làm thế nào để thuộc tính LOAIKH trong quan hệ KHACHHANG có thể lưu các giá trị là: “Vang lai”, “Thuong xuyen”, “Vip”, 
ALTER TABLE dbo.KHACHHANG
ALTER COLUMN LOAIKH VARCHAR(20)

--7. Đơn vị tính của sản phẩm chỉ có thể là (“cay”,”hop”,”cai”,”quyen”,”chuc”)
ALTER TABLE dbo.SANPHAM
ADD CONSTRAINT SANPHAM_DVT CHECK (DVT = 'cay' OR DVT = 'hop' OR DVT = 'cai' OR DVT = 'quyen' OR DVT = 'chuc')

--8 GIABAN>500

ALTER TABLE dbo.SANPHAM
ADD CONSTRAINT GIA_SP CHECK (GIA>500)

--9 KHACH HANG MUA IT NHAT 1 SP
ALTER TABLE dbo.CTHD
ADD CONSTRAINT SL_MUA CHECK ( SL>=1)

----10 Ngày khách hàng đăng ký là khách hàng thành viên phải lớn hơn ngày sinh của người đó.
ALTER TABLE dbo.KHACHHANG ADD CHECK(NGDK>NGSINH)

-- 11 -> 15 Trigger
-- 11. Ngày mua hàng (NGHD) của một khách hàng thành viên sẽ lớn hơn hoặc bằng ngày khách hàng đó đăng ký thành viên (NGDK). 
INSERT INTO HOADON VALUES (1024,'2006-01-01','KH01','NV01',0);
--TRIGGER INSERT HOADON
CREATE TRIGGER NGHD_NGDK_INSERT_HD
ON HOADON 
FOR INSERT
AS 
	DECLARE @NGHD SMALLDATETIME, @NGDK SMALLDATETIME  

	SELECT @NGHD = NGHD FROM INSERTED  
	SELECT @NGDK = NGDK FROM INSERTED, KHACHHANG 
	WHERE KHACHHANG.MAKH = INSERTED.MAKH 

	IF (@NGHD < @NGDK) 
	BEGIN
		ROLLBACK TRAN 
		RAISERROR ('NGHD PHAI LON HON NGDK',16,1) 
		RETURN 
	END 

--TRIGGER UPDATE HOADON
UPDATE HOADON 
SET NGHD = '2006-01-01'
WHERE SOHD = 1001 

CREATE TRIGGER NGHD_NGDK_UPDATE_HD

ON HOADON 
FOR UPDATE 
AS 
	DECLARE @NGHD SMALLDATETIME, @NGDK SMALLDATETIME

	SELECT @NGHD = NGHD FROM INSERTED 
	SELECT @NGDK = NGDK FROM INSERTED, KHACHHANG
	WHERE KHACHHANG.MAKH = INSERTED.MAKH

	IF (@NGHD < @NGDK) 
	BEGIN
		ROLLBACK TRAN 
		RAISERROR ('NGHD PHAI LON HON NGDK',16,1) 
		RETURN 
	END 

-- TRIGGER UPDATE KHACHHANG 
UPDATE KHACHHANG
SET NGDK ='2022-01-01'
WHERE MAKH = 'KH01'

CREATE TRIGGER NGHD_NGDK_UPDATE_KH
ON KHACHHANG
FOR UPDATE 
AS 
	DECLARE @NGHD SMALLDATETIME, @NGDK SMALLDATETIME

	SELECT @NGDK = NGDK FROM INSERTED 
	SELECT @NGHD = MIN(NGHD) FROM INSERTED,HOADON 
	WHERE INSERTED.MAKH = HOADON.MAKH 
	
	IF (@NGHD < @NGDK) 
	BEGIN
		ROLLBACK TRAN 
		RAISERROR ('NGHD PHAI LON HON NGDK',16,1) 
		RETURN 
	END
	

-- 12.	Ngày bán hàng (NGHD) của một nhân viên phải lớn hơn hoặc bằng ngày nhân viên đó vào làm

INSERT INTO HOADON VALUES (1024,'2006-01-01','KH01','NV01',320000)

UPDATE HOADON 
SET NGHD = '2006-01-01'
WHERE SOHD = 1001 

--TRIGGER INSERT UPDATE HOADON
CREATE TRIGGER NGHD_NGDK_INSERT_UPDATE_HD
ON HOADON 
FOR INSERT , UPDATE 
AS 
	DECLARE @NGHD SMALLDATETIME, @NGVL SMALLDATETIME

	SELECT @NGHD = NGHD FROM INSERTED 
	SELECT @NGVL = NGVL FROM INSERTED, NHANVIEN
	WHERE NHANVIEN.MANV = INSERTED.MANV 

	IF (@NGHD < @NGVL) 
	BEGIN
		ROLLBACK TRAN 
		RAISERROR ('NGHD PHAI LON HON NGVL',16,1) 
		RETURN 
	END 

-- TRIGGER UPDATE NHANVIEN
UPDATE NHANVIEN
SET NGVL ='2022-01-01'
WHERE MANV = 'NV01'

CREATE TRIGGER NGHD_NGDK_UPDATE_NV
ON NHANVIEN
FOR UPDATE 
AS 
	DECLARE @NGHD SMALLDATETIME, @NGVL SMALLDATETIME

	SELECT @NGVL = NGVL FROM INSERTED 
	SELECT @NGHD = MIN(NGHD) FROM INSERTED,HOADON 
	WHERE INSERTED.MANV = HOADON.MANV 
	
	IF (@NGHD < @NGVL) 
	BEGIN
		ROLLBACK TRAN 
		RAISERROR ('NGHD PHAI LON HON NGVL',16,1) 
		RETURN 
	END
	
-- 13.	Mỗi một hóa đơn phải có ít nhất một chi tiết hóa đơn.
-- 14.	Trị giá của một hóa đơn là tổng thành tiền (số lượng*đơn giá) của các chi tiết thuộc hóa đơn đó.

-- TRIGGER THAO TAC INSERT HOADON
INSERT INTO HOADON VALUES (1021, '2022-12-08', 1000000, 'KH01', 'NV01')
SELECT * FROM HOADON WHERE SOHD = 1024

CREATE TRIGGER TRIGIA_INSERT_HOADON
ON HOADON
FOR INSERT
AS
begin 
	DECLARE @SOHD INT
	SELECT @SOHD = SOHD FROM INSERTED
	
	UPDATE HOADON SET TRIGIA =0 WHERE SOHD=@SOHD
	PRINT('DA CAP NHAP TRIGIA = 0')
end
--TRIGGER UPDATE HOADON
SELECT * FROM HOADON WHERE SOHD = 1001
UPDATE HOADON SET TRIGIA = 1000000 WHERE SOHD = 1001

CREATE TRIGGER TRIGIA_UPDATE_HOADON
ON HOADON
FOR UPDATE
AS
	--KHAI BAO BIEN
	DECLARE @SOHD INT, @TRIGIA MONEY
	 
	--GAN GIA TRI CHO BIEN 
	SELECT @SOHD = SOHD FROM INSERTED
	SELECT @TRIGIA = SUM ( SL*GIA ) FROM CTHD, SANPHAM
	WHERE CTHD.MASP=SANPHAM.MASP AND SOHD=@SOHD

	-- XU LY
	UPDATE HOADON SET TRIGIA = @TRIGIA WHERE SOHD=@SOHD
	PRINT ('DA CAP TRI GIA DUNG CHO HOA DON')

--TIGGER CHO THEM MOI 1 CTHD
SELECT * FROM CTHD WHERE SOHD =1001
INSERT INTO CTHD VALUES (1001, 'BB01',10)

CREATE TRIGGER TRIGIA_INSERT_CTHD
ON CTHD
FOR INSERT
AS
	--KHAI BAO BIEN
	DECLARE @SOHD INT, @TRIGIA MONEY

	--GAN GIATRI CHO BIEN
	SELECT @SOHD=SOHD FROM INSERTED 
	SELECT @TRIGIA = SUM (SL*GIA) FROM CTHD, SANPHAM
	WHERE CTHD.MASP=SANPHAM.MASP AND SOHD=@SOHD

	--XU LY
	UPDATE HOADON SET TRIGIA = @TRIGIA WHERE SOHD = @SOHD
	PRINT ('DA CAP NHAP GIATRI MOI CHO HOADON')

-- TRIGGER CHO THAO TAC DELETE CTHD
DELETE FROM CTHD WHERE SOHD = 1001 AND MASP = 'BB01'
SELECT *FROM CTHD WHERE SOHD = 1001
SELECT *FROM HOADON WHERE SOHD = 1001

CREATE TRIGGER TRIGIA_DELETE_CTHD
ON CTHD
FOR DELETE
AS
	--KHAI BAO BIEN
	DECLARE @SOHD INT, @TRIGIA MONEY
	 
	--GAN GIA TRI CHO BIEN 
	SELECT @SOHD = SOHD FROM DELETED
	SELECT @TRIGIA = SUM ( SL*GIA ) FROM CTHD, SANPHAM
	WHERE CTHD.MASP=SANPHAM.MASP AND SOHD=@SOHD

	-- XU LY
	UPDATE HOADON SET TRIGIA = @TRIGIA WHERE SOHD=@SOHD
	PRINT ('DA CAP TRI GIA DUNG CHO HOA DON')

--TRIGGER THAO TAC CHO UPDATE CTHD
SELECT *FROM CTHD WHERE SOHD =1001 OR SOHD=1002
SELECT *FROM HOADON WHERE SOHD = 1001

UPDATE CTHD SET SOHD = 1002 WHERE SOHD = 1001 AND MASP = 'BC01'

CREATE TRIGGER TRIGIA_UPDATE_CTHD
ON CTHD
FOR UPDATE
AS
	--KHAI BAO BIEN
	DECLARE @SOHDCU INT , @TRIGIAHDCU MONEY 
	DECLARE @SOHDMOI INT , @TRIGIAHDMOI MONEY 

	--GAN GIA TRI CHO BIEN
	SELECT @SOHDCU = SOHD FROM DELETED G
	SELECT @TRIGIAHDCU = SUM (SL*GIA) FROM CTHD, SANPHAM
	WHERE CTHD.MASP = SANPHAM.MASP AND SOHD = @SOHDCU

	SELECT @SOHDMOI = SOHD FROM INSERTED
	SELECT @TRIGIAHDMOI = SUM (SL*GIA) FROM CTHD, SANPHAM
	WHERE CTHD.MASP=SANPHAM.MASP AND SOHD = @SOHDMOI

	--XULY
	UPDATE HOADON SET TRIGIA = @TRIGIAHDCU WHERE SOHD = @SOHDCU
	UPDATE HOADON SET TRIGIA = @TRIGIAHDMOI WHERE SOHD = @SOHDMOI
	PRINT ('DA CAP NHAP GIA TRI MOI CHO HOADON')

--TRIGGER CHO THAO TAC UPDATE SANPHAM
SELECT HOADON.SOHD, TRIGIA FROM CTHD, HOADON
WHERE CTHD.SOHD=HOADON.SOHD AND MASP='TV02'

UPDATE SANPHAM SET GIA = 14500 WHERE MASP = 'TV02'

CREATE TRIGGER TRIGIA_UPDATE_SANPHAM
ON SANPHAM
FOR UPDATE 
AS
	DECLARE @MASP CHAR(4)
	SELECT @MASP = MASP FROM INSERTED
	SELECT * INTO TEMP 
	FROM CTHD WHERE MASP=@MASP
	
	WHILE (EXISTS (SELECT * FROM TEMP))
	BEGIN
	DECLARE @SOHD INT, @TRIGIA MONEY 

	SELECT TOP 1 @SOHD = SOHD FROM TEMP
	SELECT @TRIGIA SUM (SL*GIA) FROM CTHD, SANPHAM
	WHERE CTHD.MASP = SANPHAM.MASP AND SOHD=@SOHD
	UPDATE HOADON SET TRIGIA = @TRIGIA WHERE SOHD= @SOHD
	DELETE FROM TEMP WHERE SOHD= @SOHD
	END

	PRINT ('DA CAP NHAP GIA TRI CUA CAC HOA DON')
	DROP TABLE TEMP
-- 15.	Doanh số của một khách hàng là tổng trị giá các hóa đơn mà khách hàng thành viên đó 

--TRIGGER CHO THAO TAC INSERT KHACHHANG
CREATE TRIGGER INSERT_KHACHHANG_C15
ON KHACHHANG
FOR INSERT
AS
BEGIN 
 DECLARE @MAKH CHAR(4)

 SELECT @MAKH=MAKH
 FROM  INSERTED
 
 UPDATE KHACHHANG
 SET  DOANHSO=0
 WHERE MAKH=@MAKH

 PRINT 'DA INSERT 1 KHACHHANG MOI VOI DOANHSO BAN DAU LA 0 VND'
END

--TRIGGER UPDATE KHACHHANG
CREATE TRIGGER UPDATE_KHACHHANG_C15
ON KHACHHANG
FOR UPDATE
AS
 DECLARE @MAKH  CHAR(4),
   @DOANHSO_CU MONEY

 SELECT @MAKH=MAKH
 FROM  INSERTED
 
 SELECT @DOANHSO_CU=DOANHSO
 FROM  DELETED
 
 UPDATE KHACHHANG
 SET  DOANHSO=@DOANHSO_CU
 WHERE MAKH=@MAKH

 PRINT 'DA UPDATE KHACHHANG'

--TRIGGER INSERT HOADON
CREATE TRIGGER INSERT_HOADON_C15
ON HOADON
FOR INSERT
AS
 DECLARE @TRIGIA MONEY,
   @MAKH CHAR(4)

 SELECT @MAKH=MAKH,@TRIGIA=TRIGIA
 FROM  INSERTED
 
 UPDATE KHACHHANG
 SET  DOANHSO=DOANHSO+@TRIGIA
 WHERE MAKH=@MAKH

 PRINT 'DA INSERT 1 HODON MOI VA UPDATE LAI DOANHSO CUA KH CO SOHD TREN'

--TRIGGER DELETE HOADON
CREATE TRIGGER DELETE_HOADON_C15
ON HOADON
FOR DELETE
AS
 DECLARE @TRIGIA MONEY,
   @MAKH CHAR(4)

 SELECT @MAKH=MAKH,@TRIGIA=TRIGIA
 FROM  DELETED
 
 UPDATE KHACHHANG
 SET  DOANHSO=DOANHSO-@TRIGIA
 WHERE MAKH=@MAKH

 PRINT 'DA DELETE 1 HOADON MOI VA UPDATE LAI DOANHSO CUA KH CO SOHD TREN'

--TRIGGER UPDATE HOADON 
CREATE TRIGGER UPDATE_HOADON_C15
ON HOADON
FOR UPDATE
AS
 DECLARE @TRIGIA_CU MONEY,
   @TRIGIA_MOI MONEY,
   @MAKH  CHAR(4)

 SELECT @MAKH=MAKH,@TRIGIA_MOI=TRIGIA
 FROM  INSERTED

 SELECT @MAKH=MAKH,@TRIGIA_CU=TRIGIA
 FROM  DELETED
  
 UPDATE KHACHHANG
 SET  DOANHSO=DOANHSO+@TRIGIA_MOI-@TRIGIA_CU
 WHERE MAKH=@MAKH

 PRINT 'DA UPDATE 1 HOADON MOI VA UPDATE LAI DOANHSO CUA KH'

--INSERT DATA

/*INSERT DU LIEU*/

INSERT INTO NHANVIEN VALUES ('NV01', 'Nguyen Nhu Nhut', '0927345678', '2006-04-13')
INSERT INTO NHANVIEN VALUES ('NV02', 'Le Thi Phi Yen', '0987567390', '2006-04-21')
INSERT INTO NHANVIEN VALUES ('NV03', 'Nguyen Van B', '0997047382', '2006-04-27')
INSERT INTO NHANVIEN VALUES ('NV04', 'Ngo Thanh Tuan', '0913758498','2006-06-24')
INSERT INTO NHANVIEN VALUES ('NV05', 'Nguyen Thi Truc Thanh','0918590387','2006-07-20')
 
/*NHAP DU LIEU KHACHHANG*/
insert into KHACHHANG (MAKH, HOTEN, DCHI, SODT, NGSINH, DOANHSO,NGDK)values('KH01','Nguyen Van A','731 Tran Hung Dao, Q5, TpHCH','08823451','1960-10-22' ,13060000, '2006-07-22')
insert into KHACHHANG (MAKH, HOTEN, DCHI, SODT, NGSINH, DOANHSO,NGDK) values('KH02','Tran Ngoc Han','23/5 Nguyen Trai, Q5, TpHCM',0908256478,'1974-03-04',280000,'2006-07-30')
insert into KHACHHANG (MAKH, HOTEN, DCHI, SODT, NGSINH, DOANHSO,NGDK) values('KH03','Tran Ngoc Linh','45 Nguyen Canh Chan, Q1, TpHCM',0938776266,'1980-12-06',3860000,'2006-05-08')
insert into KHACHHANG (MAKH, HOTEN, DCHI, SODT, NGSINH, DOANHSO,NGDK) values('KH04','Tran Minh Long','50/34 Le Dai Hanh, Q10, TpHCM',0917325476, '1965-09-03',250000,'2006-02-10')
insert into KHACHHANG (MAKH, HOTEN, DCHI, SODT, NGSINH, DOANHSO,NGDK)values('KH05','Le Nhat Minh','34 Truong Dinh, Q3, TpHCM',08246108,'1950-10-03',21000,'2006-10-28')
insert into KHACHHANG (MAKH, HOTEN, DCHI, SODT, NGSINH, DOANHSO,NGDK)values('KH06','Le Hoai Thuong','227 Nguyen Van Cu, Q5, TpHCM',08631738,'1981-12-31',915000,'2006-11-24')
insert into KHACHHANG (MAKH, HOTEN, DCHI, SODT, NGSINH, DOANHSO,NGDK)values('KH07','Nguyen Van Tam','32/3 Tran Binh Trong, Q5, TpHCM',0916783565,'1971-04-06',12500,'2006-12-01')
insert into KHACHHANG (MAKH, HOTEN, DCHI, SODT, NGSINH, DOANHSO,NGDK)values('KH08','Phan Thi Thanh','45/2 An Duong Vuong, Q5, TpHCM',0938435756,'1971-01-10',365000,'2006-12-13')
insert into KHACHHANG (MAKH, HOTEN, DCHI, SODT, NGSINH, DOANHSO,NGDK)values('KH09','Le Ha Vinh','873 Le Hong Phong, Q5, TpHCM',08654763,'1979-09-03',70000,'2007-01-14')
insert into KHACHHANG (MAKH, HOTEN, DCHI, SODT, NGSINH, DOANHSO,NGDK)values('KH10','Ha Duy Lap','34/34B Nguyen Trai, Q1, TpHCM',08768904,'1983-05-02',67500,'2007-01-16')
select*from KHACHHANG
/*NHAP DU LIEU SANPHAM*/
insert into SANPHAM values('BC01','But chi','cay','Singapore',3000) 
insert into SANPHAM values('BC02','But chi','cay',' Singapore',5000) 
insert into SANPHAM values('BC03','But chi','cay',' Viet Nam',3500)
insert into SANPHAM values('BC04','But chi','hop','Viet Nam',30000) 
insert into SANPHAM values('BB01','But bi','cay','Viet Nam',5000) 
insert into SANPHAM values('BB02','But bi','cay','Trung Quoc',7000) 
insert into SANPHAM values('BB03','But bi','hop','Thai Lan',100000) 
insert into SANPHAM values('TV01','Tap 100 giay mong','quyen','Trung Quoc',2500) 
insert into SANPHAM values('TV02','Tap 200 giay mong','quyen','Trung Quoc',4500) 
insert into SANPHAM values('TV03','Tap 100 giay tot','quyen','Viet Nam',3000) 
insert into SANPHAM values('TV04','Tap 200 giay tot','quyen','Viet Nam',5500) 
insert into SANPHAM values('TV05','Tap 100 trang','chuc','Viet Nam',23000) 
insert into SANPHAM values('TV06','Tap 200 trang','chuc','Viet Nam',53000) 
insert into SANPHAM values('TV07','Tap 100 trang','chuc','Trung Quoc',34000) 
insert into SANPHAM values('ST01','So tay 500 trang','quyen','Trung Quoc',40000) 
insert into SANPHAM values('ST02','So tay loai 1','quyen','Viet Nam',55000) 
insert into SANPHAM values('ST03','So tay loai 2','quyen','Viet Nam',51000) 
insert into SANPHAM values('ST04','So tay','quyen','Thai Lan',55000) 
insert into SANPHAM values('ST05','So tay mong','quyen','Thai Lan',20000) 
insert into SANPHAM values('ST06','Phan viet bang','hop','Viet Nam',5000) 
insert into SANPHAM values('ST07','Phan khong bui','hop','Viet Nam',7000) 
insert into SANPHAM values('ST08','Bong bang','cai','Viet Nam',1000) 
insert into SANPHAM values('ST09','But long','cay','Viet Nam',5000) 
insert into SANPHAM values('ST10','But long','cay','Trung Quoc',7000)

/*nhap du lieu SO HOA DON */
INSERT INTO HOADON VALUES ('1001','2006-07-23','KH01','NV01',320000)
INSERT INTO HOADON VALUES ('1002','2006-08-12','KH01','NV02',840000)
INSERT INTO HOADON VALUES ('1003','2006-08-23','KH02','NV01',100000)
INSERT INTO HOADON VALUES ('1004','2006-09-01','KH02','NV01',180000)
INSERT INTO HOADON VALUES ('1005','2006-10-20','KH01','NV02',3800000)
INSERT INTO HOADON VALUES ('1006','2006-10-16','KH01','NV03',2430000)
INSERT INTO HOADON VALUES ('1007','2006-10-28','KH03','NV03',510000)
INSERT INTO HOADON VALUES ('1008','2006-10-28','KH01','NV03',440000)
INSERT INTO HOADON VALUES ('1009','2006-10-28','KH03','NV04',200000)
INSERT INTO HOADON VALUES ('1010','2006-11-01','KH01','NV01',5200000)
INSERT INTO HOADON VALUES ('1011','2006-11-04','KH04','NV03',250000)
INSERT INTO HOADON VALUES ('1012','2006-11-30','KH05','NV03',21000)
INSERT INTO HOADON VALUES ('1013','2006-12-12','KH06','NV01',5000)
INSERT INTO HOADON VALUES ('1014','2006-12-31','KH03','NV02',3150000)
INSERT INTO HOADON VALUES ('1015','2007-01-01','KH06','NV01',910000)
INSERT INTO HOADON VALUES ('1016','2007-01-01','KH07','NV02',12500)
INSERT INTO HOADON VALUES ('1017','2007-01-02','KH08','NV03',35000)
INSERT INTO HOADON VALUES ('1018','2007-01-13','KH08','NV03',330000)
INSERT INTO HOADON VALUES ('1019','2007-01-13','KH01','NV03',30000)
INSERT INTO HOADON VALUES ('1020','2007-01-14','KH09','NV04',70000)
INSERT INTO HOADON VALUES ('1021','2007-01-16','KH10','NV03',67500)
INSERT INTO HOADON VALUES ('1022','2007-01-16',Null,'NV03',7000)
INSERT INTO HOADON VALUES ('1023','2007-01-17',Null,'NV01',330000)
select*from HOADON

/*nhap du lieu CHI TIET HOA DON */
 
INSERT INTO CTHD VALUES ('1001','TV02','10')
INSERT INTO CTHD VALUES ('1001','ST01','5')
INSERT INTO CTHD VALUES ('1001','BC01','5')
INSERT INTO CTHD VALUES ('1001','BC02','10')
INSERT INTO CTHD VALUES ('1001','ST08','10')
INSERT INTO CTHD VALUES ('1002','BC04','20')
INSERT INTO CTHD VALUES ('1002','BB01','20')
INSERT INTO CTHD VALUES ('1002','BB02','20')
INSERT INTO CTHD VALUES ('1003','BB03','10')
INSERT INTO CTHD VALUES ('1004','TV01','20')
INSERT INTO CTHD VALUES ('1004','TV02','10')
INSERT INTO CTHD VALUES ('1004','TV03','10')
INSERT INTO CTHD VALUES ('1004','TV04','10')
INSERT INTO CTHD VALUES ('1005','TV05','50')
INSERT INTO CTHD VALUES ('1005','TV06','50')
INSERT INTO CTHD VALUES ('1006','TV07','20')
INSERT INTO CTHD VALUES ('1006','ST01','30')
INSERT INTO CTHD VALUES ('1006','ST02','10')
INSERT INTO CTHD VALUES ('1007','ST03','10')
INSERT INTO CTHD VALUES ('1008','ST04','8')
INSERT INTO CTHD VALUES ('1009','ST05','10')
INSERT INTO CTHD VALUES ('1010','TV07','50')
INSERT INTO CTHD VALUES ('1010','ST07','50')
INSERT INTO CTHD VALUES ('1010','ST08','100')
INSERT INTO CTHD VALUES ('1010','ST04','50')
INSERT INTO CTHD VALUES ('1010','TV03','100')
INSERT INTO CTHD VALUES ('1011','ST06','50')
INSERT INTO CTHD VALUES ('1012','ST07','3')
INSERT INTO CTHD VALUES ('1013','ST08','5')
INSERT INTO CTHD VALUES ('1014','BC02','80')
INSERT INTO CTHD VALUES ('1014','BB02','100')
INSERT INTO CTHD VALUES ('1014','BC04','60')
INSERT INTO CTHD VALUES ('1014','BB01','50')
INSERT INTO CTHD VALUES ('1015','BB02','30')
INSERT INTO CTHD VALUES ('1015','BB03','7')
INSERT INTO CTHD VALUES ('1016','TV01','5')
INSERT INTO CTHD VALUES ('1017','TV02','1')
INSERT INTO CTHD VALUES ('1017','TV03','1')
INSERT INTO CTHD VALUES ('1017','TV04','5')
INSERT INTO CTHD VALUES ('1018','ST04','6')
INSERT INTO CTHD VALUES ('1019','ST05','1')
INSERT INTO CTHD VALUES ('1019','ST06','2')
INSERT INTO CTHD VALUES ('1020','ST07','10')
INSERT INTO CTHD VALUES ('1021','ST08','5')
INSERT INTO CTHD VALUES ('1021','TV01','7')
INSERT INTO CTHD VALUES ('1021','TV02','10')
INSERT INTO CTHD VALUES ('1022','ST07','1')
INSERT INTO CTHD VALUES ('1023','ST04','6')

select  * from CTHD

--2.Tạo quan hệ SANPHAM1 chứa toàn bộ dữ liệu của quan hệ SANPHAM. Tạo quan hệ KHACHHANG1 chứa toàn bộ dữ liệu của quan hệ KHACHHANG.
SELECT *INTO SANPHAM1 FROM dbo.SANPHAM
SELECT *FROM dbo.SANPHAM1

SELECT *INTO KHACHHANG1 FROM dbo.KHACHHANG
SELECT *FROM dbo.KHACHHANG1

--3. Cập nhật giá tăng 5% đối với những sản phẩm do “Thai Lan” sản xuất (cho quan hệ SANPHAM1)
UPDATE dbo.SANPHAM1
SET GIA=GIA*1.05
WHERE NUOCSX='THAI LAN'

SELECT *FROM dbo.SANPHAM1


--4. Cập nhật giá giảm 5% đối với những sản phẩm do “Trung Quoc” sản xuất có giá từ 10.000 trở xuống (cho quan hệ SANPHAM1).
UPDATE dbo.SANPHAM1
SET GIA=GIA*0.95
WHERE NUOCSX='TRUNG QUOC' AND GIA = 10000

SELECT *FROM dbo.SANPHAM1

--5
ALTER TABLE dbo.KHACHHANG
ALTER COLUMN LOAIKH VARCHAR(20)

UPDATE dbo.KHACHHANG1
SET LOAIKH = 'VIP'
WHERE (NGDK<'2007-01-02' AND DOANHSO>10000000) OR (NGDK>='2007-01-02' AND DOANHSO >=2000000)

SELECT *FROM dbo.KHACHHANG1


--III
SELECT MASP,TENSP
FROM dbo.SANPHAM
WHERE NUOCSX='TRUNG QUOC'

--2
SELECT MASP,TENSP
FROM dbo.SANPHAM
WHERE DVT ='cay' OR DVT = 'quyen'

SELECT MASP,TENSP
FROM dbo.SANPHAM
WHERE DVT IN ('	cay', 'quyen')

SELECT MASP,TENSP
FROM dbo.SANPHAM
WHERE MASP LIKE 'B%01'

--4
SELECT MASP,TENSP
FROM dbo.SANPHAM
WHERE (NUOCSX='TRUNG QUOC') AND (GIA>=30000 AND GIA<=40000)

--5
SELECT MASP,TENSP
FROM dbo.SANPHAM
WHERE (NUOCSX='THAI LAN' OR NUOCSX='TRUNG QUOC') AND (GIA>=30000 AND GIA<=40000)

--6
SELECT SOHD,TRIGIA
FROM dbo.HOADON
WHERE NGHD >= '2007-01-01' AND NGHD <='2007-01-02'

--7
SELECT SOHD, TRIGIA
FROM HOADON
WHERE MONTH(NGHD) = 1 AND YEAR(NGHD) = 2007
ORDER BY NGHD ASC, TRIGIA DESC
 
--8
SELECT KH.MAKH,HOTEN
FROM dbo.KHACHHANG KH,dbo.HOADON HD
WHERE KH.MAKH=HD.MAKH
AND HD.NGHD = '2007-01-01'

--9
SELECT HD.SOHD, HD.TRIGIA
FROM dbo.HOADON HD ,dbo.NHANVIEN NV
WHERE HD.MANV = NV.MANV
AND NGHD = '2006-10-28'
AND HOTEN = 'NGUYEN VAN B'

--10
SELECT SP.MASP, SP.TENSP
FROM KHACHHANG KH, HOADON HD, CTHD CT, SANPHAM SP
WHERE KH.HOTEN='Nguyen Van A' AND KH.MAKH = KH.MAKH AND 
YEAR(HD.NGHD)=2006 AND MONTH(HD.NGHD)=10 AND CT.SOHD=HD.SOHD AND SP.MASP=CT.MASP

--11

--C1
SELECT DISTINCT SOHD
FROM dbo.CTHD
WHERE MASP='BB01' OR MASP = 'BB02'

--C2
SELECT SOHD
FROM dbo.CTHD
WHERE MASP='BB01'

SELECT SOHD
FROM dbo.CTHD
WHERE MASP='BB02'

--12

--C1
SELECT DISTINCT SOHD
FROM dbo.CTHD
WHERE (MASP='BB01' OR MASP = 'BB02')
AND (SL BETWEEN 10 AND 20)

--C2
SELECT SOHD
FROM dbo.CTHD
WHERE MASP='BB01' AND (SL BETWEEN 10 AND 20)

SELECT SOHD
FROM dbo.CTHD
WHERE MASP='BB02' AND (SL BETWEEN 10 AND 20)


--13

--C1
SELECT SOHD
FROM dbo.CTHD
WHERE MASP='BB01' AND (SL BETWEEN 10 AND 20)
INTERSECT -- PHEP GIAO
SELECT SOHD
FROM dbo.CTHD
WHERE MASP='BB02' AND (SL BETWEEN 10 AND 20)

--C2 DUNG TOAN TU IN (CACH NAY PHO BIEN HON), CACH NAY GIONG NHU MAP 2 MANG LAI
SELECT SOHD
FROM dbo.CTHD
WHERE MASP='BB01' AND(SL BETWEEN 10 AND 20)
AND SOHD IN (SELECT SOHD
			FROM dbo.CTHD
			WHERE MASP ='BB02'
			AND SL BETWEEN 10 AND 20)

--C3 DUNG EXISTS DUYET TUNG DONG, SE CHO TOC DO TRUY VAN NHANH HON IN
SELECT SOHD
FROM dbo.CTHD A
WHERE MASP='BB01' AND(SL BETWEEN 10 AND 20)
AND EXISTS (SELECT *
			FROM dbo.CTHD B
			WHERE MASP ='BB02'
			AND SL BETWEEN 10 AND 20
			AND B.SOHD=A.SOHD)

--14
SELECT MASP, TENSP
FROM SANPHAM
WHERE NUOCSX = 'TRUNG QUOC'
UNION
SELECT SP.MASP, TENSP
FROM SANPHAM SP, HOADON HD, CTHD
WHERE SP.MASP=CTHD.MASP
AND HD.SOHD=CTHD.SOHD
AND NGHD='2007-01-01'
--15
SELECT MASP,TENSP
FROM SANPHAM

SELECT SP.MASP,TENSP
FROM CTHD,SANPHAM SP
EXCEPT
SELECT SP.MASP,TENSP
FROM CTHD, SANPHAM SP
WHERE CTHD.MASP=SP.MASP

--CACH 2
SELECT MASP, TENSP
FROM SANPHAM
WHERE MASP NOT IN (SELECT MASP FROM CTHD)

--CACH 3
SELECT MASP, TENSP
FROM SANPHAM
WHERE NOT EXISTS (SELECT *
					FROM CTHD
					WHERE CTHD.MASP = SANPHAM.MASP)

--16.	In ra danh sách các sản phẩm (MASP,TENSP) không bán được trong năm 2006.
SELECT MASP,TENSP
FROM SANPHAM

SELECT SP.MASP,TENSP
FROM CTHD,SANPHAM SP
EXCEPT
SELECT SP.MASP,TENSP
FROM CTHD, SANPHAM SP, HOADON HD
WHERE CTHD.MASP=SP.MASP
AND HD.SOHD = CTHD.SOHD
AND YEAR(NGHD)=2006

--17.	In ra danh sách các sản phẩm (MASP,TENSP) do “Trung Quoc” sản xuất không bán được trong năm 2006.
--c1
SELECT MASP, TENSP
FROM  SANPHAM
WHERE NUOCSX='TRUNG QUOC' AND
  MASP NOT IN ( SELECT A.MASP
     FROM  CTHD A, HOADON B
     WHERE A.SOHD=B.SOHD AND YEAR(NGHD)=2006)

--c2
SELECT MASP, TENSP
FROM SANPHAM
WHERE NUOCSX = 'TRUNG QUOC' AND
	NOT EXISTS (SELECT *
	FROM CTHD A, HOADON B
	WHERE A.SOHD = B.SOHD AND YEAR (NGHD) = 2006 AND A.MASP=SANPHAM.MASP
	)
--CAU LAM THEM --TIM CAC SO HOA DON DA MUA BB02 NHUNG KHONG MUA BB01
SELECT SOHD
FROM CTHD
WHERE MASP='BB02'
AND SOHD NOT IN (SELECT SOHD
FROM CTHD
WHERE MASP = 'BB01')

--CACH KHAC
SELECT SOHD
FROM CTHD C1
WHERE MASP = 'BB02' 
AND NOT EXISTS (SELECT SOHD
					FROM CTHD C2
					WHERE MASP ='BB01' 
					AND C2.SOHD=C1.SOHD)

					---18,19 ĐỀ THI NÀO CŨNG CÓ

--18.	Tìm số hóa đơn đã mua tất cả các sản phẩm do Singapore sản xuất.
SELECT SOHD
FROM HOADON
WHERE NOT EXISTS(SELECT *
					FROM SANPHAM
					WHERE NUOCSX = 'SINGAPORE' 
					AND NOT EXISTS(SELECT * 
					FROM CTHD
					WHERE CTHD.MASP = SANPHAM.MASP
					AND CTHD.SOHD=HOADON.SOHD
					))

--19.	Tìm số hóa đơn trong năm 2006 đã mua ít nhất tất cả các sản phẩm do Singapore sản xuất.
SELECT SOHD
FROM HOADON
WHERE NOT EXISTS(SELECT *
					FROM SANPHAM
					WHERE NUOCSX = 'SINGAPORE' 
					AND NOT EXISTS(SELECT * 
					FROM CTHD
					WHERE CTHD.MASP = SANPHAM.MASP
					AND CTHD.SOHD=HOADON.SOHD
					AND YEAR(NGHD)=2006	
					))

--20.	Có bao nhiêu hóa đơn không phải của khách hàng đăng ký thành viên mua?
SELECT  KHACHHANG.MAKH,HOTEN,SOHD
FROM KHACHHANG, HOADON
WHERE KHACHHANG.MAKH = HOADON.MAKH
AND NOT EXISTS (SELECT *
					FROM SANPHAM
					WHERE NUOCSX='SINGAPORE'
					AND NOT EXISTS (SELECT *
					FROM CTHD
					WHERE CTHD.MASP=SANPHAM.MASP
					AND CTHD.SOHD=HOADON.SOHD
					))

--20.	Có bao nhiêu hóa đơn không phải của khách hàng đăng ký thành viên mua?
SELECT COUNT(SOHD) SOHD
FROM HOADON
WHERE MAKH IS NULL

--21.	Có bao nhiêu sản phẩm khác nhau được bán ra trong năm 2006.
SELECT COUNT(DISTINCT MASP)
FROM  HOADON , CTHD 
WHERE HOADON.SOHD=CTHD.SOHD AND YEAR(NGHD)=2006

--22.	Cho biết trị giá hóa đơn cao nhất, thấp nhất là bao nhiêu ?
SELECT MAX(TRIGIA) [TRI GIA CAO NHAT],MIN(TRIGIA) [TRI GIA THAP NHAT] 
FROM  HOADON

--23.	Trị giá trung bình của tất cả các hóa đơn được bán ra trong năm 2006 là bao nhiêu?
SELECT AVG(TRIGIA) [TRI GIA TRUNG BINH]
FROM  HOADON
WHERE YEAR(NGHD)=2006

--24.	Tính doanh thu bán hàng trong năm 2006.
SELECT SUM(TRIGIA) [DOANH THU]
FROM  HOADON
WHERE YEAR(NGHD)=2006

--25.	Tìm số hóa đơn có trị giá cao nhất trong năm 2006.
SELECT SOHD
FROM HOADON
WHERE YEAR(NGHD)=2006
AND TRIGIA = (
SELECT MAX(TRIGIA)
FROM HOADON
WHERE YEAR(NGHD)=2006
)

--26.	Tìm họ tên khách hàng đã mua hóa đơn có trị giá cao nhất trong năm 2006.
SELECT KHACHHANG.HOTEN
FROM KHACHHANG, HOADON
WHERE HOADON.MAKH=KHACHHANG.MAKH AND 
HOADON.TRIGIA IN 
(
    SELECT MAX(hd.TRIGIA)
    FROM HOADON hd
    WHERE year(hd.NGHD)=2006
)
--C2
SELECT HOTEN
FROM KHACHHANG kh, HOADON
WHERE HOADON.MAKH = kh.MAKH and
HOADON.TRIGIA >=ALL ( SELECT max(hd.TRIGIA)
FROM HOADON hd 
WHERE year(hd.NGHD)=2006 )


--27.	In ra danh sách 3 khách hàng đầu tiên (MAKH, HOTEN) sắp xếp theo doanh số giảm dần.
SELECT TOP 3 MAKH, HOTEN,DOANHSO
FROM KHACHHANG
ORDER BY DOANHSO DESC

--28.	In ra danh sách các sản phẩm (MASP, TENSP) có giá bán bằng 1 trong 3 mức giá cao nhất.
SELECT MASP, TENSP, GIA
FROM  SANPHAM
WHERE GIA IN(SELECT DISTINCT TOP 3  GIA
    FROM   SANPHAM
    ORDER BY   GIA DESC)  

--29.	In ra danh sách các sản phẩm (MASP, TENSP) do “Thai Lan” sản xuất có giá bằng 1 trong 3 mức giá cao nhất (của tất cả các sản phẩm).
SELECT MASP, TENSP, GIA
FROM  SANPHAM
WHERE NUOCSX='THAI LAN' AND GIA IN(SELECT DISTINCT TOP 3  GIA
        FROM   SANPHAM
        ORDER BY   GIA DESC) 

--30.	In ra danh sách các sản phẩm (MASP, TENSP) do “Trung Quoc” sản xuất có giá bằng 1 trong 3 mức giá cao nhất (của sản phẩm do “Trung Quoc” sản xuất).
SELECT MASP, TENSP, GIA
FROM  SANPHAM
WHERE NUOCSX='TRUNG QUOC' AND GIA IN(SELECT DISTINCT TOP 3  GIA
        FROM   SANPHAM
        WHERE  NUOCSX='TRUNG QUOC'
        ORDER BY   GIA DESC) 

--31.	* In ra danh sách khách hàng nằm trong 3 hạng cao nhất (xếp hạng theo doanh số).
SELECT MAKH, HOTEN, DOANHSO
FROM  KHACHHANG
WHERE DOANHSO IN(SELECT DISTINCT TOP 3 DOANHSO
    FROM   KHACHHANG
    ORDER BY   DOANHSO DESC)  
ORDER BY DOANHSO DESC

--32.	Tính tổng số sản phẩm do “Trung Quoc” sản xuất.
SELECT COUNT(MASP)
FROM SANPHAM
WHERE NUOCSX='TRUNG QUOC'

--33.	Tính tổng số sản phẩm của từng nước sản xuất.
SELECT NUOCSX, COUNT(MASP) SOSP
FROM SANPHAM
GROUP BY NUOCSX

--34.	Với từng nước sản xuất, tìm giá bán cao nhất, thấp nhất, trung bình của các sản phẩm.

SELECT MAX(GIA) CAONHAT, MIN(GIA) THAPNHAT, AVG(GIA) TRUNGBINH
FROM SANPHAM
GROUP BY NUOCSX

--35.	Tính doanh thu bán hàng mỗi ngày.
SELECT NGHD, SUM(TRIGIA) DOANHTHU
FROM HOADON
GROUP BY NGHD

--36.	Tính tổng số lượng của từng sản phẩm bán ra trong tháng 10/2006.
SELECT CTHD.MASP, SUM(CTHD.SL) TONG
FROM CTHD CTHD, HOADON HD
WHERE CTHD.SOHD=HD.SOHD AND MONTH(NGHD)=10 AND YEAR(NGHD)=2006 
GROUP BY CTHD.MASP

--37.	Tính doanh thu bán hàng của từng tháng trong năm 2006.
SELECT MONTH(HD.NGHD) THANG , SUM(HD.TRIGIA) TONG
FROM HOADON HD 
WHERE YEAR(HD.NGHD)=2006
GROUP BY MONTH(HD.NGHD)

--38.	Tìm hóa đơn có mua ít nhất 4 sản phẩm khác nhau.
SELECT DISTINCT SOHD, COUNT(MASP) SLSP
FROM CTHD
GROUP BY SOHD
HAVING COUNT (MASP) >=4

--39.	Tìm hóa đơn có mua 3 sản phẩm do “Viet Nam” sản xuất (3 sản phẩm khác nhau).
SELECT SOHD, COUNT(CTHD.MASP) SLSP
FROM SANPHAM SP, CTHD
WHERE SP.MASP=CTHD.MASP AND NUOCSX='VIET NAM'
GROUP BY SOHD
HAVING COUNT (CTHD.MASP)=3

--40.	Tìm khách hàng (MAKH, HOTEN) có số lần mua hàng nhiều nhất. 
--C1 IT XAI
SELECT KHACHHANG.MAKH, HOTEN, COUNT(SOHD) SLMUA
FROM KHACHHANG, HOADON
WHERE KHACHHANG.MAKH=HOADON.MAKH
GROUP BY KHACHHANG.MAKH, HOTEN
HAVING COUNT(SOHD)= (SELECT TOP 1 COUNT(SOHD)
					FROM HOADON
					GROUP BY MAKH
					ORDER BY COUNT (SOHD) DESC)

--C2 HAY XAI
SELECT KHACHHANG.MAKH, HOTEN, COUNT(SOHD) SLMUA
FROM KHACHHANG, HOADON
WHERE KHACHHANG.MAKH=HOADON.MAKH
GROUP BY KHACHHANG.MAKH, HOTEN
HAVING COUNT(SOHD) >= ALL(SELECT COUNT (SOHD)
							FROM HOADON
							GROUP BY MAKH)
--C3
SELECT TOP 1 WITH TIES KHACHHANG.MAKH, HOTEN, COUNT(SOHD) SLMUA
FROM KHACHHANG, HOADON
WHERE KHACHHANG.MAKH=HOADON.MAKH
GROUP BY KHACHHANG.MAKH, HOTEN
ORDER BY COUNT(SOHD) DESC

--41.	Tháng mấy trong năm 2006, doanh số bán hàng cao nhất ?
SELECT MONTH(HD.NGHD) THANG
FROM HOADON HD
WHERE YEAR(HD.NGHD)=2006
GROUP BY MONTH(HD.NGHD)
HAVING SUM(HD.TRIGIA)>=ALL (
   SELECT SUM(HD.TRIGIA)
   FROM HOADON HD
   WHERE YEAR(HD.NGHD) = 2006
   GROUP BY MONTH(HD.NGHD)
							)
--C2
SELECT TOP 1 WITH TIES MONTH(HD.NGHD) THANG
FROM HOADON HD
WHERE YEAR(HD.NGHD)=2006
GROUP BY MONTH(HD.NGHD)
ORDER BY SUM(HD.TRIGIA) DESC

--42.	Tìm sản phẩm (MASP, TENSP) có tổng số lượng bán ra thấp nhất trong năm 2006.
SELECT CTHD.MASP, SP.TENSP
FROM CTHD CTHD, HOADON HD, SANPHAM SP 
WHERE CTHD.SOHD = HD.SOHD 
AND YEAR(HD.NGHD)=2006 AND SP.MASP =CTHD.MASP
GROUP BY CTHD.MASP, SP.TENSP
HAVING SUM(CTHD.SL) <= ALL (
    SELECT SUM(CTHD.SL)
    FROM CTHD CTHD, HOADON HD 
    WHERE CTHD.SOHD = HD.SOHD 
	AND YEAR(HD.NGHD)=2006
    GROUP BY CTHD.MASP
							)

--43.	*Mỗi nước sản xuất, tìm sản phẩm (MASP,TENSP) có giá bán cao nhất.
SELECT NUOCSX, MASP, TENSP, GIA
FROM SANPHAM SP1
WHERE GIA = (SELECT MAX(GIA)
			FROM SANPHAM SP2
			WHERE SP2.NUOCSX = SP1.NUOCSX
			)
--44.	Tìm nước sản xuất sản xuất ít nhất 3 sản phẩm có giá bán khác nhau.
SELECT NUOCSX, COUNT (DISTINCT GIA)
FROM SANPHAM
GROUP BY NUOCSX
HAVING COUNT(DISTINCT GIA) >= 3

--45.	*Trong 10 khách hàng có doanh số cao nhất, tìm khách hàng có số lần mua hàng nhiều nhất.
--C1
SELECT TOP 1 WITH TIES  KHACHHANG.MAKH, HOTEN, COUNT (SOHD)
FROM KHACHHANG, HOADON
WHERE DOANHSO IN (SELECT  DISTINCT TOP 3 DOANHSO
					FROM KHACHHANG
					ORDER BY DOANHSO DESC
					)
AND KHACHHANG.MAKH=HOADON.MAKH
GROUP BY KHACHHANG.MAKH, HOTEN
ORDER BY COUNT (SOHD) ASC

--C2
SELECT KHACHHANG.MAKH, HOTEN, COUNT (SOHD)
FROM KHACHHANG, HOADON
WHERE DOANHSO IN (SELECT  DISTINCT TOP 3 DOANHSO
					FROM KHACHHANG
					ORDER BY DOANHSO DESC
					)
AND KHACHHANG.MAKH=HOADON.MAKH
GROUP BY KHACHHANG.MAKH, HOTEN
HAVING COUNT(SOHD) <= ALL(SELECT COUNT (SOHD)
							FROM KHACHHANG, HOADON
							WHERE KHACHHANG.MAKH=HOADON.MAKH
							AND DOANHSO IN(SELECT DISTINCT TOP 3 DOANHSO
							FROM KHACHHANG
							ORDER BY DOANHSO DESC)
							GROUP BY KHACHHANG.MAKH
							)

--19 KHONG DUNG NOT EXIST 19.	Tìm số hóa đơn trong năm 2006 đã mua ít nhất tất cả các sản phẩm do Singapore sản xuất.
SELECT KHACHHANG.MAKH, HOTEN,HOADON.SOHD, COUNT (SANPHAM.MASP) TONGSOHD
FROM HOADON, KHACHHANG, CTHD, SANPHAM
WHERE HOADON.MAKH = KHACHHANG.MAKH
AND CTHD.SOHD=HOADON.SOHD
AND SANPHAM.MASP=CTHD.MASP
AND NUOCSX = 'SINGAPORE'
GROUP BY KHACHHANG.MAKH, HOTEN,HOADON.SOHD
HAVING COUNT (SANPHAM.MASP)  = (SELECT COUNT (MASP)
							FROM SANPHAM
							WHERE NUOCSX = 'SINGAPORE'
							)

--46 TRONG KHACH HANG CO SO LAN MUA IT NHAT , TIM DOANH SO CAO NHAT.
SELECT TOP 1 WITH TIES KHACHHANG.MAKH, HOTEN,DOANHSO,  COUNT(SOHD) SLMUA
FROM KHACHHANG, HOADON
WHERE KHACHHANG.MAKH=HOADON.MAKH
GROUP BY KHACHHANG.MAKH, HOTEN, DOANHSO
HAVING COUNT(SOHD) <=ALL (SELECT COUNT(SOHD)
					FROM HOADON
					GROUP BY MAKH)
ORDER BY DOANHSO DESC

--C2
SELECT KHACHHANG.MAKH, HOTEN, DOANHSO, COUNT(SOHD) SLMUA
FROM KHACHHANG, HOADON
WHERE KHACHHANG.MAKH=HOADON.MAKH
AND DOANHSO=(SELECT TOP 1 DOANHSO
			FROM KHACHHANG, HOADON
			WHERE KHACHHANG.MAKH=HOADON.MAKH
			GROUP BY KHACHHANG.MAKH, DOANHSO
			HAVING COUNT(SOHD) <=ALL(
								SELECT COUNT(SOHD)
								FROM HOADON
								GROUP BY MAKH
			)
			ORDER BY DOANHSO DESC
			)
GROUP BY KHACHHANG.MAKH, HOTEN, DOANHSO
HAVING COUNT (SOHD) <= ALL(
		SELECT COUNT(SOHD)
		FROM HOADON
		GROUP BY MAKH
	)