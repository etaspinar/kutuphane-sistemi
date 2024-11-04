*&---------------------------------------------------------------------*
*& Report ZKUTUPHANEYONETIMSISTEMI
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zkutuphaneyonetimsistemi.


**Kitap Bilgileri
DATA: gv_kod         TYPE int4,
      gv_ad          TYPE char30,
      gv_sayfa       TYPE int4,
      gv_tur         TYPE char20,
      gv_yazar       TYPE char30,
      gv_basimtarihi TYPE datum,
      gv_stok        TYPE int4.

**Kullanıcı bilgileri
DATA: gv_kullaniciid       TYPE int4,
      gv_kullaniciad       TYPE char15,
      gv_kullanicisoyad    TYPE char15,
      gv_kullaniciyas      TYPE int4,
      gv_kullanicitelefon  TYPE char11,
      gv_kullanicimail     TYPE char30,
      gv_kullanıcıcinsiyet TYPE char5.

DATA: gv_kitapkod         TYPE zkitapbilgi-kod,
      gv_kullaniciids     TYPE zkullanicibilgi-kullaniciid,
      gv_odunc_tarihi     TYPE datum,
      gv_teslim_tarihi    TYPE datum,
      gv_durum            TYPE char1,
      gv_kullaniciisim    TYPE zkullanicibilgi-kullaniciad,
      gv_kullanicisoyisim TYPE zkullanicibilgi-kullanicisoyad,
      gv_kitapad          TYPE zkitapbilgi-ad,
      gv_kitapyazar       TYPE zkitapbilgi-yazar.

DATA: gt_kitapodunc TYPE TABLE OF zkitapodunc,
      gs_kitapodunc TYPE zkitapodunc.

DATA: gt_kitapkayit TYPE TABLE OF zkitapbilgi,
      gs_kitapkayit TYPE zkitapbilgi.

DATA: gt_kullanicibilgi TYPE TABLE OF zkullanicibilgi,
      gs_kullanicibilgi TYPE zkullanicibilgi.

DATA: gv_page_start TYPE i VALUE 0, " Başlangıç satırı
      gv_page_size  TYPE i VALUE 50. " Sayfa başına satır sayısı

DATA: g_kitapliste_itab TYPE TABLE OF zkitapbilgi,
      g_kitapliste_wa   TYPE zkitapbilgi. " Work area

DATA: g_kullanicibilgi_itab TYPE TABLE OF zkullanicibilgi,
      g_kullanicibilgi_wa   TYPE zkullanicibilgi. " Work area

DATA: g_kitapodunc_itab TYPE TABLE OF zkitapodunc,
      g_kitapodunc_wa   TYPE zkitapodunc. " Work area

TYPES: BEGIN OF t_kitapliste,
         kod         LIKE zkitapbilgi-kod,
         ad          LIKE zkitapbilgi-ad,
         sayfa       LIKE zkitapbilgi-sayfa,
         tur         LIKE zkitapbilgi-tur,
         yazar       LIKE zkitapbilgi-yazar,
         basimtarihi LIKE zkitapbilgi-basimtarihi,
         stok        LIKE zkitapbilgi-stok,
       END OF t_kitapliste.

DATA: p_search_name TYPE zkitapbilgi-ad,
      p_delete_kod  TYPE zkitapbilgi-kod.

DATA: p_srch_name    TYPE zkullanicibilgi-kullaniciad,
      p_delete_by_id TYPE zkullanicibilgi-kullaniciid.

DATA: g_kitapliste_lines TYPE i.

DATA: kitap_sayisi     TYPE i,
      kullanici_sayisi TYPE i.

DATA: lv_total TYPE i.


CONTROLS kutuphane TYPE TABSTRIP.
CONTROLS kitapliste TYPE TABLEVIEW USING SCREEN 0104.
CONTROLS kullanicibilgi TYPE TABLEVIEW USING SCREEN 0105.
CONTROLS kitapodunc TYPE TABLEVIEW USING SCREEN 0107.

START-OF-SELECTION.
  CALL SCREEN 0100.



*& Module STATUS_0100 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_0100 OUTPUT.
  SET PF-STATUS '0100'.
* SET TITLEBAR 'xxx'.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0100 INPUT.
  CASE sy-ucomm.
    WHEN '&BACK'.
      LEAVE TO SCREEN 0.
    WHEN '&TB1'.
      kutuphane-activetab = '&TB1'.
    WHEN '&TB2'.
      kutuphane-activetab = '&TB2'.
    WHEN '&TB3'.
      kutuphane-activetab = '&TB3'.
    WHEN '&TB4'.
      kutuphane-activetab = '&TB4'.
    WHEN '&TB5'.
      kutuphane-activetab = '&TB5'.
    WHEN '&TB6'.
      kutuphane-activetab = '&TB6'.
    WHEN '&TB7'.
      kutuphane-activetab = '&TB7'.
  ENDCASE.
ENDMODULE.

MODULE pbo_0101 OUTPUT.

  " Kitap ve kullanıcı sayısını veritabanından alıyoruz
  DATA: lv_kitap_sayisi     TYPE i,
        lv_kullanici_sayisi TYPE i.

  " Kitap sayısını veritabanından al
  SELECT COUNT( * ) INTO lv_kitap_sayisi FROM zkitapbilgi.

  " Kullanıcı sayısını veritabanından al
  SELECT COUNT( * ) INTO lv_kullanici_sayisi FROM zkullanicibilgi.

  " Global değişkenlere değer atama
  kitap_sayisi = lv_kitap_sayisi.
  kullanici_sayisi = lv_kullanici_sayisi.

  " Ekran alanlarını görünür ve sadece okunabilir olarak ayarlama
  LOOP AT SCREEN.
    IF screen-name = 'KITAP_SAYISI'.
      MODIFY SCREEN.
    ELSEIF screen-name = 'KULLANICI_SAYISI'.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.

ENDMODULE.


*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0102  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0102 INPUT.
  CASE sy-ucomm.
    WHEN '&CLEAR'.
      CLEAR: gv_kod,
             gv_ad,
             gv_sayfa,
             gv_tur,
             gv_yazar,
             gv_basimtarihi,
             gv_stok.

    WHEN '&SAVE'.

      IF  gv_kod IS INITIAL.
        MESSAGE 'Kitap Kodu Eklenmelidir.' TYPE 'I'.
        EXIT.
      ENDIF.

      IF  gv_ad IS INITIAL.
        MESSAGE 'Kitap Adı Eklenmelidir.' TYPE 'I'.
        EXIT.
      ENDIF.

      IF  gv_sayfa IS INITIAL.
        MESSAGE 'Kitap Sayfa Sayısı Eklenmelidir.' TYPE 'I'.
        EXIT.
      ENDIF.

      IF  gv_tur IS INITIAL.
        MESSAGE 'Kitap Türü Eklenmelidir.' TYPE 'I'.
        EXIT.
      ENDIF.

      IF  gv_yazar IS INITIAL.
        MESSAGE 'Kitap Yazarı Eklenmelidir.' TYPE 'I'.
        EXIT.
      ENDIF.

      IF  gv_basimtarihi IS INITIAL.
        MESSAGE 'Kitap Basım Tarihi Eklenmelidir.' TYPE 'I'.
        EXIT.
      ENDIF.

      IF  gv_stok IS INITIAL.
        MESSAGE 'Kitap Stok Sayısı   Eklenmelidir.' TYPE 'I'.
        EXIT.
      ENDIF.

      gs_kitapkayit-ad = gv_ad.
      gs_kitapkayit-kod = gv_kod.
      gs_kitapkayit-basimtarihi = gv_basimtarihi.
      gs_kitapkayit-sayfa = gv_sayfa.
      gs_kitapkayit-stok = gv_stok.
      gs_kitapkayit-tur = gv_tur.
      gs_kitapkayit-yazar = gv_yazar.

      INSERT zkitapbilgi FROM gs_kitapkayit.
      IF sy-subrc = 0.
        MESSAGE 'Yeni Kitap Başarıyla Eklendi.' TYPE 'I'.
      ELSE.
        MESSAGE 'Kitap Eklenemedi, Aynı Koda Sahip Kitap Mevcut.' TYPE 'I'.
        EXIT.
      ENDIF.


    WHEN '&UPDATE'.
      SELECT SINGLE * FROM zkitapbilgi
      INTO gs_kitapkayit
      WHERE kod = gv_kod.

      IF sy-subrc = 0.
        gs_kitapkayit-kod           = gv_kod.
        gs_kitapkayit-ad            = gv_ad.
        gs_kitapkayit-basimtarihi   = gv_basimtarihi.
        gs_kitapkayit-sayfa         = gv_sayfa.
        gs_kitapkayit-stok          = gv_stok.
        gs_kitapkayit-tur           = gv_tur.
        gs_kitapkayit-yazar         = gv_yazar.

        UPDATE zkitapbilgi FROM gs_kitapkayit.

        IF sy-subrc = 0.
          MESSAGE 'Kitap bilgileri güncellendi.' TYPE 'I'.
        ELSE.
          MESSAGE 'Kitap bilgileri güncellenemedi.' TYPE 'I'.
        ENDIF.

        COMMIT WORK AND WAIT.
      ELSE.
        MESSAGE 'Kitap bulunamadı. Güncelleme yapılamadı.' TYPE 'I'.
      ENDIF.


    WHEN '&SEARCH'.
      SELECT SINGLE * FROM zkitapbilgi
        INTO gs_kitapkayit
        WHERE kod = gv_kod.

      IF sy-subrc = 0.

        gv_kod =         gs_kitapkayit-kod.
        gv_ad =          gs_kitapkayit-ad.
        gv_basimtarihi = gs_kitapkayit-basimtarihi.
        gv_sayfa =       gs_kitapkayit-sayfa.
        gv_stok =        gs_kitapkayit-stok.
        gv_tur =         gs_kitapkayit-tur.
        gv_yazar =       gs_kitapkayit-yazar.
        MESSAGE 'Kitap bilgileri getirildi.' TYPE 'S'.
      ELSE.
        MESSAGE 'Kitap bulunamadı.' TYPE 'E'.
        CLEAR: gv_kod, gv_ad, gv_sayfa, gv_tur, gv_yazar, gv_basimtarihi, gv_stok.
      ENDIF.


  ENDCASE.
ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0104  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0104 INPUT.
  CASE sy-ucomm.
    WHEN '&REFRESH'.
      PERFORM load_page_data.

    WHEN '&SRCH'.
      PERFORM search_by_name USING p_search_name.

    WHEN '&DELETE'.
      PERFORM delete_by_kod USING p_delete_kod.
  ENDCASE.
ENDMODULE.



FORM load_page_data.
  DATA: lv_total TYPE i.

  SELECT COUNT(*) INTO @lv_total FROM zkitapbilgi.

  SELECT mandt, kod, ad, sayfa, tur, yazar, basimtarihi, stok
    FROM zkitapbilgi
    ORDER BY kod
    INTO TABLE @gt_kitapkayit
    UP TO @gv_page_size ROWS
    OFFSET @gv_page_start.

  IF sy-subrc = 0.
    CLEAR g_kitapliste_itab.
    REFRESH g_kitapliste_itab.

    LOOP AT gt_kitapkayit INTO g_kitapliste_wa.
      APPEND g_kitapliste_wa TO g_kitapliste_itab.
    ENDLOOP.

    REFRESH CONTROL 'KITAPLISTE' FROM SCREEN '0104'.

    kitapliste-lines = lines( g_kitapliste_itab ).

    MESSAGE 'Veriler yüklendi.' TYPE 'S'.
  ELSE.
    MESSAGE 'Veri çekme sırasında hata oluştu.' TYPE 'E'.
  ENDIF.
ENDFORM.



FORM search_by_name USING lv_search_name TYPE zkitapbilgi-ad.
  DATA: lv_name_temp TYPE zkitapbilgi-ad.
  " Joker karakterleri arama kriterine ekliyoruz
  CONCATENATE '%' lv_search_name '%' INTO lv_name_temp.
  " Veritabanından kitap adını aramak
  SELECT *
    FROM zkitapbilgi
    WHERE ad LIKE @lv_name_temp
    ORDER BY kod
    INTO TABLE @gt_kitapkayit.
  IF sy-subrc = 0.
    " Eğer veri varsa tabloyu dolduruyoruz
    CLEAR g_kitapliste_itab.
    REFRESH g_kitapliste_itab.
    LOOP AT gt_kitapkayit INTO g_kitapliste_wa.
      APPEND g_kitapliste_wa TO g_kitapliste_itab.
    ENDLOOP.

  ENDIF.
ENDFORM.


FORM delete_by_kod USING lv_delete_kod TYPE zkitapbilgi-kod.
  DATA: lv_answer   TYPE c,
        lv_new_id   TYPE i,
        lt_kitaplar TYPE TABLE OF zkitapbilgi,
        ls_kitap    TYPE zkitapbilgi.

  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      titlebar              = 'Silme Onayı'
      text_question         = 'Kitabı silmek istediğinize emin misiniz?'
      text_button_1         = 'Evet'
      text_button_2         = 'Hayır'
      default_button        = '2'
      display_cancel_button = ' '
    IMPORTING
      answer                = lv_answer.

  IF lv_answer = '1'.
    DELETE FROM zkitapbilgi
      WHERE kod = p_delete_kod.

    IF sy-subrc = 0.
      MESSAGE 'Kitap başarıyla silindi.' TYPE 'I'.
      CLEAR: gv_ad,
             gv_kod,
             gv_basimtarihi,
             gv_sayfa,
             gv_stok,
             gv_tur,
             gv_yazar.


      COMMIT WORK AND WAIT.

      SELECT * FROM zkitapbilgi
        INTO TABLE lt_kitaplar
        ORDER BY kod.

    ELSE.
      MESSAGE 'Kitap silinemedi. ID bulunamadı.' TYPE 'I'.
    ENDIF.

  ELSE.
    MESSAGE 'Silme işlemi iptal edildi.' TYPE 'I'.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0103  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0103 INPUT.
  CASE sy-ucomm.
    WHEN '&CLR'.
      CLEAR: gv_kullaniciid,
             gv_kullaniciad,
             gv_kullanicisoyad,
             gv_kullanicicinsiyet,
             gv_kullanicimail,
             gv_kullanicitelefon,
             gv_kullaniciyas.

    WHEN '&SV'.

      IF  gv_kullaniciid IS INITIAL.
        MESSAGE 'Kullanıcı ID Eklenmelidir.' TYPE 'I'.
        EXIT.
      ENDIF.

      IF  gv_kullaniciad IS INITIAL.
        MESSAGE 'Kullanıcı Adı Eklenmelidir.' TYPE 'I'.
        EXIT.
      ENDIF.

      IF  gv_kullanicisoyad IS INITIAL.
        MESSAGE 'Kullanıcı Soyad Eklenmelidir.' TYPE 'I'.
        EXIT.
      ENDIF.

      IF  gv_kullanicicinsiyet IS INITIAL.
        MESSAGE 'Cinsiyet Eklenmelidir.' TYPE 'I'.
        EXIT.
      ENDIF.

      IF  gv_kullanicimail IS INITIAL.
        MESSAGE 'Mail Adresi Eklenmelidir.' TYPE 'I'.
        EXIT.
      ENDIF.

      IF  gv_kullanicitelefon IS INITIAL.
        MESSAGE 'Telefon Numarası Eklenmelidir.' TYPE 'I'.
        EXIT.
      ENDIF.

      IF  gv_kullaniciyas IS INITIAL.
        MESSAGE 'Kullanıcı Yaşı Eklenmelidir.' TYPE 'I'.
        EXIT.
      ENDIF.

      gs_kullanicibilgi-kullaniciid        =      gv_kullaniciid.
      gs_kullanicibilgi-kullaniciad        =      gv_kullaniciad.
      gs_kullanicibilgi-kullanicisoyad     =      gv_kullanicisoyad.
      gs_kullanicibilgi-kullanicitelefon   =      gv_kullanicitelefon.
      gs_kullanicibilgi-kullaniciyas       =      gv_kullaniciyas.
      gs_kullanicibilgi-kullanicicinsiyet  =      gv_kullanicicinsiyet.
      gs_kullanicibilgi-kullanicimail      =      gv_kullanicimail.

      INSERT zkullanicibilgi FROM gs_kullanicibilgi.
      IF sy-subrc = 0.
        MESSAGE 'Yeni Kullanıcı Başarıyla Eklendi.' TYPE 'I'.
      ELSE.
        MESSAGE 'Kullanıcı Eklenemedi, Aynı IDye Sahip Kullanıcı Mevcut.' TYPE 'I'.
        EXIT.
      ENDIF.


    WHEN '&UPDT'.
      SELECT SINGLE * FROM zkullanicibilgi
      INTO gs_kullanicibilgi
      WHERE kullaniciid = gv_kullaniciid.

      IF  gv_kullaniciid IS INITIAL.
        MESSAGE 'Kullanıcı ID Eklenmelidir.' TYPE 'I'.
        EXIT.
      ENDIF.

      IF  gv_kullaniciad IS INITIAL.
        MESSAGE 'Kullanıcı Adı Eklenmelidir.' TYPE 'I'.
        EXIT.
      ENDIF.

      IF  gv_kullanicisoyad IS INITIAL.
        MESSAGE 'Kullanıcı Soyad Eklenmelidir.' TYPE 'I'.
        EXIT.
      ENDIF.

      IF  gv_kullanicicinsiyet IS INITIAL.
        MESSAGE 'Cinsiyet Eklenmelidir.' TYPE 'I'.
        EXIT.
      ENDIF.

      IF  gv_kullanicimail IS INITIAL.
        MESSAGE 'Mail Adresi Eklenmelidir.' TYPE 'I'.
        EXIT.
      ENDIF.

      IF  gv_kullanicitelefon IS INITIAL.
        MESSAGE 'Telefon Numarası Eklenmelidir.' TYPE 'I'.
        EXIT.
      ENDIF.

      IF  gv_kullaniciyas IS INITIAL.
        MESSAGE 'Kullanıcı Yaşı Eklenmelidir.' TYPE 'I'.
        EXIT.
      ENDIF.
      IF sy-subrc = 0.

        gs_kullanicibilgi-kullaniciid       =  gv_kullaniciid.
        gs_kullanicibilgi-kullaniciad       =  gv_kullaniciad.
        gs_kullanicibilgi-kullanicisoyad    =  gv_kullanicisoyad.
        gs_kullanicibilgi-kullaniciyas      =  gv_kullaniciyas.
        gs_kullanicibilgi-kullanicitelefon  =  gv_kullanicitelefon.
        gs_kullanicibilgi-kullanicicinsiyet =  gv_kullanicicinsiyet.
        gs_kullanicibilgi-kullanicimail     =  gv_kullanicimail.

        UPDATE zkullanicibilgi FROM gs_kullanicibilgi.

        IF sy-subrc = 0.
          MESSAGE 'Kullanıcı bilgileri güncellendi.' TYPE 'I'.
        ELSE.
          MESSAGE 'Kullanıcı bilgileri güncellenemedi.' TYPE 'I'.
        ENDIF.

        COMMIT WORK AND WAIT.
      ELSE.
        MESSAGE 'Kullanıcı bulunamadı. Güncelleme yapılamadı.' TYPE 'I'.
      ENDIF.


    WHEN '&SRC'.
      SELECT SINGLE * FROM zkullanicibilgi
        INTO gs_kullanicibilgi
        WHERE kullaniciid = gv_kullaniciid.

      IF sy-subrc = 0.

        gv_kullaniciid       =  gs_kullanicibilgi-kullaniciid.
        gv_kullaniciad       =  gs_kullanicibilgi-kullaniciad.
        gv_kullanicisoyad    =  gs_kullanicibilgi-kullanicisoyad.
        gv_kullaniciyas      =  gs_kullanicibilgi-kullaniciyas.
        gv_kullanicitelefon  =  gs_kullanicibilgi-kullanicitelefon.
        gv_kullanicicinsiyet =  gs_kullanicibilgi-kullanicicinsiyet.
        gv_kullanicimail     =  gs_kullanicibilgi-kullanicimail.

        MESSAGE 'Kullanıcı bilgileri getirildi.' TYPE 'S'.
      ELSE.
        MESSAGE 'Kullanıcı bulunamadı.' TYPE 'E'.

        CLEAR: gv_kullaniciid, gv_kullaniciad, gv_kullanicisoyad, gv_kullanicimail, gv_kullanicitelefon, gv_kullaniciyas, gv_kullanicicinsiyet.
      ENDIF.


  ENDCASE.
ENDMODULE.


*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0105  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0105 INPUT.
  CASE sy-ucomm.
    WHEN '&RFRS'.
      PERFORM load_user_data.

    WHEN '&SRCHH'.
      PERFORM search_user_name USING p_srch_name.

    WHEN '&DLTT'.
      PERFORM delete_by_id USING p_delete_by_id.
  ENDCASE.
ENDMODULE.

FORM load_user_data.
  DATA: lv_total TYPE i.

  SELECT COUNT(*) INTO @lv_total FROM zkullanicibilgi.

  SELECT mandt, kullaniciid, kullaniciad, kullanicisoyad, kullaniciyas, kullanicitelefon,kullanicimail,kullanicicinsiyet
    FROM zkullanicibilgi
    ORDER BY kullaniciid
    INTO TABLE @gt_kullanicibilgi
    UP TO @gv_page_size ROWS
    OFFSET @gv_page_start.

  IF sy-subrc = 0.
    CLEAR g_kullanicibilgi_itab.
    REFRESH g_kullanicibilgi_itab.

    LOOP AT gt_kullanicibilgi INTO g_kullanicibilgi_wa.
      APPEND g_kullanicibilgi_wa TO g_kullanicibilgi_itab.
    ENDLOOP.

    REFRESH CONTROL 'KULLANICIBILGI' FROM SCREEN '0105'.

    kullanicibilgi-lines = lines( g_kullanicibilgi_itab ).

    MESSAGE 'Veriler yüklendi.' TYPE 'S'.
  ELSE.
    MESSAGE 'Veri çekme sırasında hata oluştu.' TYPE 'E'.
  ENDIF.
ENDFORM.



FORM delete_by_id USING lv_delete_id TYPE zkullanicibilgi-kullaniciid.
  DATA: lv_ans          TYPE c,
        lv_new_id       TYPE i,
        lt_kullanicilar TYPE TABLE OF zkullanicibilgi,
        ls_kullanici    TYPE zkullanicibilgi.

  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      titlebar              = 'Silme Onayı'
      text_question         = 'Kullanıcıyı silmek istediğinize emin misiniz?'
      text_button_1         = 'Evet'
      text_button_2         = 'Hayır'
      default_button        = '2'
      display_cancel_button = ' '
    IMPORTING
      answer                = lv_ans.

  IF lv_ans = '1'.
    DELETE FROM zkullanicibilgi
      WHERE kullaniciid = p_delete_by_id.

    IF sy-subrc = 0.
      MESSAGE 'Kullanıcı başarıyla silindi.' TYPE 'I'.
      CLEAR: gv_kullaniciid,
             gv_kullaniciad,
             gv_kullanicisoyad,
             gv_kullanicicinsiyet,
             gv_kullanicimail,
             gv_kullanicitelefon,
             gv_kullaniciyas.


      COMMIT WORK AND WAIT.

      SELECT * FROM zkullanicibilgi
        INTO TABLE lt_kullanicilar
        ORDER BY kullaniciid.

    ELSE.
      MESSAGE 'Kullanıcı silinemedi. ID bulunamadı.' TYPE 'I'.
    ENDIF.

  ELSE.
    MESSAGE 'Silme işlemi iptal edildi.' TYPE 'I'.
  ENDIF.
ENDFORM.


FORM search_user_name USING lv_search_name TYPE zkullanicibilgi-kullaniciad.
  DATA: lv_name_temp TYPE zkitapbilgi-ad.
  " Joker karakterleri arama kriterine ekliyoruz
  CONCATENATE '%' lv_search_name '%' INTO lv_name_temp.
  " Veritabanından kitap adını aramak
  SELECT *
    FROM zkullanicibilgi
    WHERE kullaniciad LIKE @lv_name_temp
    ORDER BY kullaniciid
    INTO TABLE @gt_kullanicibilgi.
  IF sy-subrc = 0.
    " Eğer veri varsa tabloyu dolduruyoruz
    CLEAR g_kullanicibilgi_itab .
    REFRESH g_kullanicibilgi_itab.
    LOOP AT gt_kullanicibilgi INTO g_kullanicibilgi_wa.
      APPEND g_kullanicibilgi_wa TO g_kullanicibilgi_itab.
    ENDLOOP.

  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0106  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0106 INPUT.
  CASE sy-ucomm.
    WHEN '&TESLIMET'. " Teslim etme işlemi

      IF gv_ad IS INITIAL.
        MESSAGE 'Teslim edilecek kitap adı girilmelidir.' TYPE 'E'.
        EXIT.
      ENDIF.

      " Kitap adı ile ilgili kaydı bul ve sil
      DELETE FROM zkitapodunc
        WHERE kitapad = gv_ad.

      IF sy-subrc = 0.
        MESSAGE 'Kitap başarıyla teslim edildi ve kayıttan silindi.' TYPE 'S'.
      ELSE.
        MESSAGE 'Kitap teslim edilirken hata oluştu.' TYPE 'E'.


      ENDIF.

      WHEN '&REFRESH'.

        " Toplam kayıt sayısını alın
        SELECT COUNT(*) INTO @lv_total FROM zkitapodunc.

        " Tabloyu temizle ve yenile
        CLEAR gt_kitapodunc.
        REFRESH gt_kitapodunc.
        CLEAR g_kitapodunc_itab.
        REFRESH g_kitapodunc_itab.

        " Eğer veritabanında veri yoksa bilgi mesajı döndür
        IF lv_total = 0.
          REFRESH CONTROL 'KITAPODUNC' FROM SCREEN '0106'.
          MESSAGE 'Gösterilecek veri yok.' TYPE 'I'.
        ELSE.
          " Verileri çek
          SELECT mandt, kullaniciids, kitapkod, odunc_tarihi, teslim_tarihi, kitapad, kitapyazar, kullaniciisim, kullanicisoyisim
            FROM zkitapodunc
            ORDER BY kullaniciids
            INTO TABLE @gt_kitapodunc
            UP TO @gv_page_size ROWS
            OFFSET @gv_page_start.

          IF sy-subrc = 0.
            " Gelen verileri işlem tablosuna ekle
            LOOP AT gt_kitapodunc INTO g_kitapodunc_wa.
              APPEND g_kitapodunc_wa TO g_kitapodunc_itab.
            ENDLOOP.

            " Ekranı yenile
            REFRESH CONTROL 'KITAPODUNC' FROM SCREEN '0106'.

            kitapodunc-lines = lines( g_kitapodunc_itab ).
            MESSAGE 'Veriler yüklendi.' TYPE 'S'.
          ELSE.
            MESSAGE 'Veri çekme sırasında hata oluştu.' TYPE 'E'.
          ENDIF.
        ENDIF.


  ENDCASE.

ENDMODULE.



*
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0107  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0107 INPUT.
  CASE sy-ucomm.
    WHEN '&ODUNCVER'. " Ödünç verme işlemi

      IF gv_kullaniciid IS INITIAL OR gv_kod IS INITIAL.
        MESSAGE 'Kullanıcı ID ve Kitap Kodu girilmelidir.' TYPE 'E'.
        EXIT.
      ENDIF.

      " Kitap koduna göre kitap veritabanında mevcut mu kontrol et
      SELECT SINGLE * FROM zkitapbilgi
        INTO gs_kitapkayit
        WHERE kod = gv_kod.

      IF sy-subrc <> 0.
        MESSAGE 'Bu kitap mevcut değil.' TYPE 'E'.
        EXIT.
      ENDIF.
*
      " Kitap daha önce ödünç verilmiş mi kontrol et
      SELECT SINGLE *
        FROM zkitapodunc
        INTO gs_kitapodunc
        WHERE kitapkod = gv_kod.

      IF sy-subrc = 0.
        MESSAGE 'Bu kitap zaten ödünç verilmiş.' TYPE 'E'.
        EXIT.
      ENDIF.


      CLEAR gs_kitapodunc.
      gs_kitapodunc-kullaniciids = gv_kullaniciid.
      gs_kitapodunc-kitapkod = gv_kod.
      gs_kitapodunc-odunc_tarihi = gv_odunc_tarihi.
      gs_kitapodunc-teslim_tarihi = gv_teslim_tarihi.
      gs_kitapodunc-kitapad = gv_ad.
      gs_kitapodunc-kitapyazar = gv_yazar.
      gs_kitapodunc-kullaniciisim = gv_kullaniciad.
      gs_kitapodunc-kullanicisoyisim = gv_kullanicisoyad.

      INSERT zkitapodunc FROM gs_kitapodunc.

      IF sy-subrc = 0.
        MESSAGE 'Kitap başarıyla ödünç verildi.' TYPE 'S'.
      ELSE.
        MESSAGE 'Kitap ödünç verilemedi.' TYPE 'E'.
      ENDIF.

    WHEN '&CLEAR'. " Alanları temizle
      CLEAR: gv_kullaniciid, gv_kod, gv_teslim_tarihi, gv_kullaniciad, gv_kullanicisoyad, gv_ad, gv_yazar,gv_odunc_tarihi.

    WHEN '&GTR'. " Kullanıcı ve Kitap Bilgilerini Getir
      " Kullanıcı bilgilerini getirme
      SELECT SINGLE * FROM zkullanicibilgi
        INTO gs_kullanicibilgi
        WHERE kullaniciid = gv_kullaniciid.

      IF sy-subrc = 0.
        gv_kullaniciid    =  gs_kullanicibilgi-kullaniciid.
        gv_kullaniciad    =  gs_kullanicibilgi-kullaniciad.
        gv_kullanicisoyad =  gs_kullanicibilgi-kullanicisoyad.
      ELSE.
        MESSAGE 'Kullanıcı bulunamadı.' TYPE 'E'.
        EXIT.
      ENDIF.

      " Kitap bilgilerini getirme
      SELECT SINGLE * FROM zkitapbilgi
        INTO gs_kitapkayit
        WHERE kod = gv_kod.

      IF sy-subrc = 0.
        gv_kod   = gs_kitapkayit-kod. " gv_kod doğru atanıyor
        gv_ad    = gs_kitapkayit-ad.
        gv_yazar = gs_kitapkayit-yazar.
      ELSE.
        MESSAGE 'Kitap bulunamadı.' TYPE 'E'.
        EXIT.
      ENDIF.

      MESSAGE 'Kullanıcı ve Kitap bilgileri getirildi.' TYPE 'S'.

    WHEN '&REFRESH'.


      " Toplam kayıt sayısını alın
      SELECT COUNT(*) INTO @lv_total FROM zkitapodunc.

      " Tabloyu temizle ve yenile
      CLEAR gt_kitapodunc.
      REFRESH gt_kitapodunc.
      CLEAR g_kitapodunc_itab.
      REFRESH g_kitapodunc_itab.

      " Eğer veritabanında veri yoksa bilgi mesajı döndür
      IF lv_total = 0.
        REFRESH CONTROL 'KITAPODUNC' FROM SCREEN '0107'.
        MESSAGE 'Gösterilecek veri yok.' TYPE 'I'.
      ELSE.
        " Verileri çek
        SELECT mandt, kullaniciids, kitapkod, odunc_tarihi, teslim_tarihi, kitapad, kitapyazar, kullaniciisim, kullanicisoyisim
          FROM zkitapodunc
          ORDER BY kullaniciids
          INTO TABLE @gt_kitapodunc
          UP TO @gv_page_size ROWS
          OFFSET @gv_page_start.

        IF sy-subrc = 0.
          " Gelen verileri işlem tablosuna ekle
          LOOP AT gt_kitapodunc INTO g_kitapodunc_wa.
            APPEND g_kitapodunc_wa TO g_kitapodunc_itab.
          ENDLOOP.

          " Ekranı yenile
          REFRESH CONTROL 'KITAPODUNC' FROM SCREEN '0107'.

          kitapodunc-lines = lines( g_kitapodunc_itab ).
          MESSAGE 'Veriler yüklendi.' TYPE 'S'.
        ELSE.
          MESSAGE 'Veri çekme sırasında hata oluştu.' TYPE 'E'.
        ENDIF.
      ENDIF.

  ENDCASE.
ENDMODULE.









***&SPWIZARD: DATA DECLARATION FOR TABLECONTROL 'KITAPLISTE'
*&SPWIZARD: DEFINITION OF DDIC-TABLE
TABLES:   zkitapbilgi.

*&SPWIZARD: TYPE FOR THE DATA OF TABLECONTROL 'KITAPLISTE'
*TYPES: BEGIN OF t_kitapliste,
*         kod         LIKE zkitapbilgi-kod,
*         ad          LIKE zkitapbilgi-ad,
*         sayfa       LIKE zkitapbilgi-sayfa,
*         tur         LIKE zkitapbilgi-tur,
*         yazar       LIKE zkitapbilgi-yazar,
*         basimtarihi LIKE zkitapbilgi-basimtarihi,
*         stok        LIKE zkitapbilgi-stok,
*       END OF t_kitapliste.

*&SPWIZARD: INTERNAL TABLE FOR TABLECONTROL 'KITAPLISTE'
*DATA: g_kitapliste_wa   TYPE t_kitapliste. "work area
*      g_kitapliste_itab TYPE t_kitapliste OCCURS 0,
DATA:     g_kitapliste_copied.           "copy flag

*&SPWIZARD: DECLARATION OF TABLECONTROL 'KITAPLISTE' ITSELF
*CONTROLS: kitapliste TYPE TABLEVIEW USING SCREEN 0104.

*&SPWIZARD: LINES OF TABLECONTROL 'KITAPLISTE'
*DATA:     g_kitapliste_lines  LIKE sy-loopc.

DATA:     ok_code LIKE sy-ucomm.

*&SPWIZARD: OUTPUT MODULE FOR TC 'KITAPLISTE'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: COPY DDIC-TABLE TO ITAB
MODULE kitapliste_init OUTPUT.
  IF g_kitapliste_copied IS INITIAL.
*&SPWIZARD: COPY DDIC-TABLE 'ZKITAPBILGI'
*&SPWIZARD: INTO INTERNAL TABLE 'g_KITAPLISTE_itab'
    SELECT * FROM zkitapbilgi
       INTO CORRESPONDING FIELDS
       OF TABLE g_kitapliste_itab.
    g_kitapliste_copied = 'X'.
    REFRESH CONTROL 'KITAPLISTE' FROM SCREEN '0104'.
  ENDIF.
ENDMODULE.

*&SPWIZARD: OUTPUT MODULE FOR TC 'KITAPLISTE'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: MOVE ITAB TO DYNPRO
MODULE kitapliste_move OUTPUT.
  MOVE-CORRESPONDING g_kitapliste_wa TO zkitapbilgi.
ENDMODULE.

*&SPWIZARD: OUTPUT MODULE FOR TC 'KITAPLISTE'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: GET LINES OF TABLECONTROL
MODULE kitapliste_get_lines OUTPUT.
  g_kitapliste_lines = sy-loopc.
ENDMODULE.

*&SPWIZARD: INPUT MODULE FOR TC 'KITAPLISTE'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: PROCESS USER COMMAND
MODULE kitapliste_user_command INPUT.
  ok_code = sy-ucomm.
  PERFORM user_ok_tc USING    'KITAPLISTE'
                              'G_KITAPLISTE_ITAB'
                              'FLAG'
                     CHANGING ok_code.
  sy-ucomm = ok_code.
ENDMODULE.

*----------------------------------------------------------------------*
*   INCLUDE TABLECONTROL_FORMS                                         *
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  USER_OK_TC                                               *
*&---------------------------------------------------------------------*
FORM user_ok_tc USING    p_tc_name TYPE dynfnam
                         p_table_name
                         p_mark_name
                CHANGING p_ok      LIKE sy-ucomm.

*&SPWIZARD: BEGIN OF LOCAL DATA----------------------------------------*
  DATA: l_ok     TYPE sy-ucomm,
        l_offset TYPE i.
*&SPWIZARD: END OF LOCAL DATA------------------------------------------*

*&SPWIZARD: Table control specific operations                          *
*&SPWIZARD: evaluate TC name and operations                            *
  SEARCH p_ok FOR p_tc_name.
  IF sy-subrc <> 0.
    EXIT.
  ENDIF.
  l_offset = strlen( p_tc_name ) + 1.
  l_ok = p_ok+l_offset.
*&SPWIZARD: execute general and TC specific operations                 *
  CASE l_ok.
    WHEN 'INSR'.                      "insert row
      PERFORM fcode_insert_row USING    p_tc_name
                                        p_table_name.
      CLEAR p_ok.

    WHEN 'DELE'.                      "delete row
      PERFORM fcode_delete_row USING    p_tc_name
                                        p_table_name
                                        p_mark_name.
      CLEAR p_ok.

    WHEN 'P--' OR                     "top of list
         'P-'  OR                     "previous page
         'P+'  OR                     "next page
         'P++'.                       "bottom of list
      PERFORM compute_scrolling_in_tc USING p_tc_name
                                            l_ok.
      CLEAR p_ok.
*     WHEN 'L--'.                       "total left
*       PERFORM FCODE_TOTAL_LEFT USING P_TC_NAME.
*
*     WHEN 'L-'.                        "column left
*       PERFORM FCODE_COLUMN_LEFT USING P_TC_NAME.
*
*     WHEN 'R+'.                        "column right
*       PERFORM FCODE_COLUMN_RIGHT USING P_TC_NAME.
*
*     WHEN 'R++'.                       "total right
*       PERFORM FCODE_TOTAL_RIGHT USING P_TC_NAME.
*
    WHEN 'MARK'.                      "mark all filled lines
      PERFORM fcode_tc_mark_lines USING p_tc_name
                                        p_table_name
                                        p_mark_name   .
      CLEAR p_ok.

    WHEN 'DMRK'.                      "demark all filled lines
      PERFORM fcode_tc_demark_lines USING p_tc_name
                                          p_table_name
                                          p_mark_name .
      CLEAR p_ok.

*     WHEN 'SASCEND'   OR
*          'SDESCEND'.                  "sort column
*       PERFORM FCODE_SORT_TC USING P_TC_NAME
*                                   l_ok.

  ENDCASE.

ENDFORM.                              " USER_OK_TC

*&---------------------------------------------------------------------*
*&      Form  FCODE_INSERT_ROW                                         *
*&---------------------------------------------------------------------*
FORM fcode_insert_row
              USING    p_tc_name           TYPE dynfnam
                       p_table_name             .

*&SPWIZARD: BEGIN OF LOCAL DATA----------------------------------------*
  DATA l_lines_name       LIKE feld-name.
  DATA l_selline          LIKE sy-stepl.
  DATA l_lastline         TYPE i.
  DATA l_line             TYPE i.
  DATA l_table_name       LIKE feld-name.
  FIELD-SYMBOLS <tc>                 TYPE cxtab_control.
  FIELD-SYMBOLS <table>              TYPE STANDARD TABLE.
  FIELD-SYMBOLS <lines>              TYPE i.
*&SPWIZARD: END OF LOCAL DATA------------------------------------------*

  ASSIGN (p_tc_name) TO <tc>.

*&SPWIZARD: get the table, which belongs to the tc                     *
  CONCATENATE p_table_name '[]' INTO l_table_name. "table body
  ASSIGN (l_table_name) TO <table>.                "not headerline

*&SPWIZARD: get looplines of TableControl                              *
  CONCATENATE 'G_' p_tc_name '_LINES' INTO l_lines_name.
  ASSIGN (l_lines_name) TO <lines>.

*&SPWIZARD: get current line                                           *
  GET CURSOR LINE l_selline.
  IF sy-subrc <> 0.                   " append line to table
    l_selline = <tc>-lines + 1.
*&SPWIZARD: set top line                                               *
    IF l_selline > <lines>.
      <tc>-top_line = l_selline - <lines> + 1 .
    ELSE.
      <tc>-top_line = 1.
    ENDIF.
  ELSE.                               " insert line into table
    l_selline = <tc>-top_line + l_selline - 1.
    l_lastline = <tc>-top_line + <lines> - 1.
  ENDIF.
*&SPWIZARD: set new cursor line                                        *
  l_line = l_selline - <tc>-top_line + 1.

*&SPWIZARD: insert initial line                                        *
  INSERT INITIAL LINE INTO <table> INDEX l_selline.
  <tc>-lines = <tc>-lines + 1.
*&SPWIZARD: set cursor                                                 *
  SET CURSOR LINE l_line.

ENDFORM.                              " FCODE_INSERT_ROW

*&---------------------------------------------------------------------*
*&      Form  FCODE_DELETE_ROW                                         *
*&---------------------------------------------------------------------*
FORM fcode_delete_row
              USING    p_tc_name           TYPE dynfnam
                       p_table_name
                       p_mark_name   .

*&SPWIZARD: BEGIN OF LOCAL DATA----------------------------------------*
  DATA l_table_name       LIKE feld-name.

  FIELD-SYMBOLS <tc>         TYPE cxtab_control.
  FIELD-SYMBOLS <table>      TYPE STANDARD TABLE.
  FIELD-SYMBOLS <wa>.
  FIELD-SYMBOLS <mark_field>.
*&SPWIZARD: END OF LOCAL DATA------------------------------------------*

  ASSIGN (p_tc_name) TO <tc>.

*&SPWIZARD: get the table, which belongs to the tc                     *
  CONCATENATE p_table_name '[]' INTO l_table_name. "table body
  ASSIGN (l_table_name) TO <table>.                "not headerline

*&SPWIZARD: delete marked lines                                        *
  DESCRIBE TABLE <table> LINES <tc>-lines.

  LOOP AT <table> ASSIGNING <wa>.

*&SPWIZARD: access to the component 'FLAG' of the table header         *
    ASSIGN COMPONENT p_mark_name OF STRUCTURE <wa> TO <mark_field>.

    IF <mark_field> = 'X'.
      DELETE <table> INDEX syst-tabix.
      IF sy-subrc = 0.
        <tc>-lines = <tc>-lines - 1.
      ENDIF.
    ENDIF.
  ENDLOOP.

ENDFORM.                              " FCODE_DELETE_ROW

*&---------------------------------------------------------------------*
*&      Form  COMPUTE_SCROLLING_IN_TC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_TC_NAME  name of tablecontrol
*      -->P_OK       ok code
*----------------------------------------------------------------------*
FORM compute_scrolling_in_tc USING    p_tc_name
                                      p_ok.
*&SPWIZARD: BEGIN OF LOCAL DATA----------------------------------------*
  DATA l_tc_new_top_line     TYPE i.
  DATA l_tc_name             LIKE feld-name.
  DATA l_tc_lines_name       LIKE feld-name.
  DATA l_tc_field_name       LIKE feld-name.

  FIELD-SYMBOLS <tc>         TYPE cxtab_control.
  FIELD-SYMBOLS <lines>      TYPE i.
*&SPWIZARD: END OF LOCAL DATA------------------------------------------*

  ASSIGN (p_tc_name) TO <tc>.
*&SPWIZARD: get looplines of TableControl                              *
  CONCATENATE 'G_' p_tc_name '_LINES' INTO l_tc_lines_name.
  ASSIGN (l_tc_lines_name) TO <lines>.


*&SPWIZARD: is no line filled?                                         *
  IF <tc>-lines = 0.
*&SPWIZARD: yes, ...                                                   *
    l_tc_new_top_line = 1.
  ELSE.
*&SPWIZARD: no, ...                                                    *
    CALL FUNCTION 'SCROLLING_IN_TABLE'
      EXPORTING
        entry_act      = <tc>-top_line
        entry_from     = 1
        entry_to       = <tc>-lines
        last_page_full = 'X'
        loops          = <lines>
        ok_code        = p_ok
        overlapping    = 'X'
      IMPORTING
        entry_new      = l_tc_new_top_line
      EXCEPTIONS
*       NO_ENTRY_OR_PAGE_ACT  = 01
*       NO_ENTRY_TO    = 02
*       NO_OK_CODE_OR_PAGE_GO = 03
        OTHERS         = 0.
  ENDIF.

*&SPWIZARD: get actual tc and column                                   *
  GET CURSOR FIELD l_tc_field_name
             AREA  l_tc_name.

  IF syst-subrc = 0.
    IF l_tc_name = p_tc_name.
*&SPWIZARD: et actual column                                           *
      SET CURSOR FIELD l_tc_field_name LINE 1.
    ENDIF.
  ENDIF.

*&SPWIZARD: set the new top line                                       *
  <tc>-top_line = l_tc_new_top_line.


ENDFORM.                              " COMPUTE_SCROLLING_IN_TC

*&---------------------------------------------------------------------*
*&      Form  FCODE_TC_MARK_LINES
*&---------------------------------------------------------------------*
*       marks all TableControl lines
*----------------------------------------------------------------------*
*      -->P_TC_NAME  name of tablecontrol
*----------------------------------------------------------------------*
FORM fcode_tc_mark_lines USING p_tc_name
                               p_table_name
                               p_mark_name.
*&SPWIZARD: EGIN OF LOCAL DATA-----------------------------------------*
  DATA l_table_name       LIKE feld-name.

  FIELD-SYMBOLS <tc>         TYPE cxtab_control.
  FIELD-SYMBOLS <table>      TYPE STANDARD TABLE.
  FIELD-SYMBOLS <wa>.
  FIELD-SYMBOLS <mark_field>.
*&SPWIZARD: END OF LOCAL DATA------------------------------------------*

  ASSIGN (p_tc_name) TO <tc>.

*&SPWIZARD: get the table, which belongs to the tc                     *
  CONCATENATE p_table_name '[]' INTO l_table_name. "table body
  ASSIGN (l_table_name) TO <table>.                "not headerline

*&SPWIZARD: mark all filled lines                                      *
  LOOP AT <table> ASSIGNING <wa>.

*&SPWIZARD: access to the component 'FLAG' of the table header         *
    ASSIGN COMPONENT p_mark_name OF STRUCTURE <wa> TO <mark_field>.

    <mark_field> = 'X'.
  ENDLOOP.
ENDFORM.                                          "fcode_tc_mark_lines

*&---------------------------------------------------------------------*
*&      Form  FCODE_TC_DEMARK_LINES
*&---------------------------------------------------------------------*
*       demarks all TableControl lines
*----------------------------------------------------------------------*
*      -->P_TC_NAME  name of tablecontrol
*----------------------------------------------------------------------*
FORM fcode_tc_demark_lines USING p_tc_name
                                 p_table_name
                                 p_mark_name .
*&SPWIZARD: BEGIN OF LOCAL DATA----------------------------------------*
  DATA l_table_name       LIKE feld-name.

  FIELD-SYMBOLS <tc>         TYPE cxtab_control.
  FIELD-SYMBOLS <table>      TYPE STANDARD TABLE.
  FIELD-SYMBOLS <wa>.
  FIELD-SYMBOLS <mark_field>.
*&SPWIZARD: END OF LOCAL DATA------------------------------------------*

  ASSIGN (p_tc_name) TO <tc>.

*&SPWIZARD: get the table, which belongs to the tc                     *
  CONCATENATE p_table_name '[]' INTO l_table_name. "table body
  ASSIGN (l_table_name) TO <table>.                "not headerline

*&SPWIZARD: demark all filled lines                                    *
  LOOP AT <table> ASSIGNING <wa>.

*&SPWIZARD: access to the component 'FLAG' of the table header         *
    ASSIGN COMPONENT p_mark_name OF STRUCTURE <wa> TO <mark_field>.

    <mark_field> = space.
  ENDLOOP.
ENDFORM.                                          "fcode_tc_mark_lines


***&SPWIZARD: DATA DECLARATION FOR TABLECONTROL 'KULLANICIBILGI'
*&SPWIZARD: DEFINITION OF DDIC-TABLE
TABLES:   zkullanicibilgi.

*&SPWIZARD: TYPE FOR THE DATA OF TABLECONTROL 'KULLANICIBILGI'
TYPES: BEGIN OF t_kullanicibilgi,
         kullaniciid       LIKE zkullanicibilgi-kullaniciid,
         kullaniciad       LIKE zkullanicibilgi-kullaniciad,
         kullanicisoyad    LIKE zkullanicibilgi-kullanicisoyad,
         kullaniciyas      LIKE zkullanicibilgi-kullaniciyas,
         kullanicitelefon  LIKE zkullanicibilgi-kullanicitelefon,
         kullanicimail     LIKE zkullanicibilgi-kullanicimail,
         kullanicicinsiyet LIKE zkullanicibilgi-kullanicicinsiyet,
       END OF t_kullanicibilgi.

*&SPWIZARD: INTERNAL TABLE FOR TABLECONTROL 'KULLANICIBILGI'
*DATA:     G_KULLANICIBILGI_ITAB   TYPE T_KULLANICIBILGI OCCURS 0,
*          G_KULLANICIBILGI_WA     TYPE T_KULLANICIBILGI. "work area
DATA:     g_kullanicibilgi_copied.           "copy flag

*&SPWIZARD: DECLARATION OF TABLECONTROL 'KULLANICIBILGI' ITSELF
*CONTROLS: KULLANICIBILGI TYPE TABLEVIEW USING SCREEN 0105.

*&SPWIZARD: OUTPUT MODULE FOR TC 'KULLANICIBILGI'. DO NOT CHANGE THIS LI
*&SPWIZARD: COPY DDIC-TABLE TO ITAB
MODULE kullanicibilgi_init OUTPUT.
  IF g_kullanicibilgi_copied IS INITIAL.
*&SPWIZARD: COPY DDIC-TABLE 'ZKULLANICIBILGI'
*&SPWIZARD: INTO INTERNAL TABLE 'g_KULLANICIBILGI_itab'
    SELECT * FROM zkullanicibilgi
       INTO CORRESPONDING FIELDS
       OF TABLE g_kullanicibilgi_itab.
    g_kullanicibilgi_copied = 'X'.
    REFRESH CONTROL 'KULLANICIBILGI' FROM SCREEN '0105'.
  ENDIF.
ENDMODULE.

*&SPWIZARD: OUTPUT MODULE FOR TC 'KULLANICIBILGI'. DO NOT CHANGE THIS LI
*&SPWIZARD: MOVE ITAB TO DYNPRO
MODULE kullanicibilgi_move OUTPUT.
  MOVE-CORRESPONDING g_kullanicibilgi_wa TO zkullanicibilgi.
ENDMODULE.



***&SPWIZARD: DATA DECLARATION FOR TABLECONTROL 'KITAPODUNC'
*&SPWIZARD: DEFINITION OF DDIC-TABLE
TABLES:   zkitapodunc.

*&SPWIZARD: TYPE FOR THE DATA OF TABLECONTROL 'KITAPODUNC'
TYPES: BEGIN OF t_kitapodunc,
         odunc_tarihi     LIKE zkitapodunc-odunc_tarihi,
         teslim_tarihi    LIKE zkitapodunc-teslim_tarihi,
         kitapad          LIKE zkitapodunc-kitapad,
         kullaniciisim    LIKE zkitapodunc-kullaniciisim,
         kullanicisoyisim LIKE zkitapodunc-kullanicisoyisim,
       END OF t_kitapodunc.

*&SPWIZARD: INTERNAL TABLE FOR TABLECONTROL 'KITAPODUNC'
*DATA: g_kitapodunc_itab TYPE t_kitapodunc OCCURS 0,
*      g_kitapodunc_wa   TYPE t_kitapodunc. "work area
DATA:     g_kitapodunc_copied.           "copy flag

*&SPWIZARD: DECLARATION OF TABLECONTROL 'KITAPODUNC' ITSELF
*CONTROLS: kitapodunc TYPE TABLEVIEW USING SCREEN 0107.

*&SPWIZARD: OUTPUT MODULE FOR TC 'KITAPODUNC'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: COPY DDIC-TABLE TO ITAB
MODULE kitapodunc_init OUTPUT.
  IF g_kitapodunc_copied IS INITIAL.
*&SPWIZARD: COPY DDIC-TABLE 'ZKITAPODUNC'
*&SPWIZARD: INTO INTERNAL TABLE 'g_KITAPODUNC_itab'
    SELECT * FROM zkitapodunc
       INTO CORRESPONDING FIELDS
       OF TABLE g_kitapodunc_itab.
    g_kitapodunc_copied = 'X'.
    REFRESH CONTROL 'KITAPODUNC' FROM SCREEN '0107'.
  ENDIF.
ENDMODULE.

*&SPWIZARD: OUTPUT MODULE FOR TC 'KITAPODUNC'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: MOVE ITAB TO DYNPRO
MODULE kitapodunc_move OUTPUT.
  MOVE-CORRESPONDING g_kitapodunc_wa TO zkitapodunc.
ENDMODULE.