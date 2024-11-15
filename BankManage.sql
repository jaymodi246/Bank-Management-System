PGDMP     %    2            	    {            BankManagementSystem    15.2    15.2 )    (           0    0    ENCODING    ENCODING        SET client_encoding = 'UTF8';
                      false            )           0    0 
   STDSTRINGS 
   STDSTRINGS     (   SET standard_conforming_strings = 'on';
                      false            *           0    0 
   SEARCHPATH 
   SEARCHPATH     8   SELECT pg_catalog.set_config('search_path', '', false);
                      false            +           1262    17073    BankManagementSystem    DATABASE     �   CREATE DATABASE "BankManagementSystem" WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE_PROVIDER = libc LOCALE = 'English_United States.1252';
 &   DROP DATABASE "BankManagementSystem";
                postgres    false            �            1255    25035 $   add_money(integer, numeric, integer) 	   PROCEDURE     p  CREATE PROCEDURE public.add_money(IN acc integer, IN bal numeric, IN password integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Authenticate the account using CheckAccountPassword function
    PERFORM 1 FROM Account WHERE Account_No = acc AND CheckAccountPassword(acc, password) = 'Authentication successful';
    
    IF FOUND THEN
        -- Update the account balance if authentication is successful
        UPDATE Account SET Balance = Balance + bal WHERE Account_No = acc;
        RAISE NOTICE 'Money added successfully';
    ELSE
        RAISE NOTICE 'Authentication failed. Money not added.';
    END IF;
END;
$$;
 V   DROP PROCEDURE public.add_money(IN acc integer, IN bal numeric, IN password integer);
       public          postgres    false            �            1255    25038 �   addaccount(bigint, character varying, numeric, character varying, character varying, bigint, character varying, character varying, integer) 	   PROCEDURE     �  CREATE PROCEDURE public.addaccount(IN acc bigint, IN acc_type character varying, IN bal numeric, IN f_name character varying, IN l_name character varying, IN ph_num bigint, IN address character varying, IN city character varying, IN password integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Insert into account_holder table with the Password column
    INSERT INTO account_holder (account_no, first_name, last_name, phone_number, address, city, password)
    VALUES (acc, f_name, l_name, ph_num, address, city, password);
    
    -- Insert into the Account table
    INSERT INTO account (account_no, account_type, balance)
    VALUES (acc, acc_type, bal);
END;
$$;
 �   DROP PROCEDURE public.addaccount(IN acc bigint, IN acc_type character varying, IN bal numeric, IN f_name character varying, IN l_name character varying, IN ph_num bigint, IN address character varying, IN city character varying, IN password integer);
       public          postgres    false            �            1255    17142 8   addbranch(integer, character varying, character varying) 	   PROCEDURE       CREATE PROCEDURE public.addbranch(IN b_id integer, IN branch_name character varying, IN branch_address character varying)
    LANGUAGE plpgsql
    AS $$
begin
    Insert into Branch values(B_id,Branch_name,Branch_address);
    -- Kai k banavu padse to check line by line
ENd;
$$;
 y   DROP PROCEDURE public.addbranch(IN b_id integer, IN branch_name character varying, IN branch_address character varying);
       public          postgres    false            �            1255    17135    check_account_number()    FUNCTION     /  CREATE FUNCTION public.check_account_number() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
Declare
    Acc1 int:=0;
begin
    Select Account_No into Acc1 from Account where Account_No=new.Account_No;
    if Acc1=0 then 
        raise 'There is no Account of this Account Number.';
    End if;
End
$$;
 -   DROP FUNCTION public.check_account_number();
       public          postgres    false            �            1255    17119    check_accounttype()    FUNCTION     �  CREATE FUNCTION public.check_accounttype() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    Acc INT := 0;
    Acc_type VARCHAR(50);
    Acc_Bal INT := 0;
BEGIN
    SELECT Account_No, Account_Type, Balance INTO Acc, Acc_type, Acc_Bal FROM Account WHERE Account_No = NEW.Account_No;
    
    IF Acc = 0 THEN
        RAISE EXCEPTION 'There is no account with this Account Number.';
    ELSE
        IF Acc_type <> 'Fixed Deposit' THEN
            RAISE EXCEPTION 'Invalid Type for this Account Number.';
        ELSE
            IF Acc_Bal < NEW.AMOUNT THEN
                RAISE EXCEPTION 'Insufficient Balance.';
            END IF;
        END IF;
    END IF;

    RETURN NEW;
END;
$$;
 *   DROP FUNCTION public.check_accounttype();
       public          postgres    false            �            1255    17130    check_transfer_balance()    FUNCTION       CREATE FUNCTION public.check_transfer_balance() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    Acc1 int := 0;
    Bal NUMERIC;
BEGIN
    SELECT Balance, Account_No INTO Bal, Acc1 FROM Account WHERE Account_No = NEW.Account_No;
    
    IF Acc1 = 0 THEN 
        RAISE EXCEPTION 'There is no Account of this Account Number.';
    ELSE 
        IF NEW.Balance < 0 THEN 
            RAISE EXCEPTION 'Insufficient Balance.';
        END IF;
    END IF;

    RETURN NEW; -- Return the trigger record
END 
$$;
 /   DROP FUNCTION public.check_transfer_balance();
       public          postgres    false            �            1255    25034 &   checkaccountpassword(integer, integer)    FUNCTION     <  CREATE FUNCTION public.checkaccountpassword(account_number integer, input_password integer) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
DECLARE 
    stored_password INTEGER;
BEGIN
    -- Get the stored password for the given account number
    SELECT password INTO stored_password FROM account_holder WHERE account_no = account_number;

    -- Check if the input password matches the stored password
    IF stored_password = input_password THEN
        RETURN 'Authentication successful';
    ELSE
        RETURN 'Authentication failed';
    END IF;
END;
$$;
 [   DROP FUNCTION public.checkaccountpassword(account_number integer, input_password integer);
       public          postgres    false            �            1255    17129 $   insert_fd(integer, integer, integer) 	   PROCEDURE     �  CREATE PROCEDURE public.insert_fd(IN acc integer, IN amt integer, IN years integer, OUT returnamt numeric)
    LANGUAGE plpgsql
    AS $$
declare
    cus_Fname account_holder.First_Name%type;
    cus_Lname account_holder.Last_Name%type;
    Acc_Number int;
    Acc_Type varchar(50);
    cal_return NUMERIC;
begin
    Select Account_No, Account_Type into Acc_Number, Acc_Type from Account where Account_No = Acc;
    Select First_Name, Last_Name into cus_Fname, cus_Lname from account_holder where Account_No = Acc;
    if years = 1 OR years < 3 then
        cal_return = amt * 1.07;
    elsif years = 3 OR years < 5 then
        cal_return = amt * 1.085;
    else   
        cal_return = amt * 1.095;
    end if;
    insert into FD values (Acc, cus_Fname, cus_Lname, amt, years, cal_return);
    update Account Set Balance = Balance - amt where Account_No = Acc;
    
    -- Assign the value to the OUT parameter directly
    returnamt = cal_return;
End 
$$;
 j   DROP PROCEDURE public.insert_fd(IN acc integer, IN amt integer, IN years integer, OUT returnamt numeric);
       public          postgres    false            �            1255    17140    retrive_fd_money(integer) 	   PROCEDURE     A  CREATE PROCEDURE public.retrive_fd_money(IN acc integer)
    LANGUAGE plpgsql
    AS $$
Declare
    retrive_amt NUMERIC;
begin
    Select RETURN_VALUE into retrive_amt from FD where Account_No=Acc;
    update Account set Balance=retrive_amt+Balance where Account_No=Acc;
    Delete from FD where  Account_No=Acc;
End
$$;
 8   DROP PROCEDURE public.retrive_fd_money(IN acc integer);
       public          postgres    false            �            1255    25039 &   search_by_city_name(character varying) 	   PROCEDURE     t  CREATE PROCEDURE public.search_by_city_name(IN p_city character varying)
    LANGUAGE plpgsql
    AS $$
DECLARE
    cus_Fname account_holder.First_Name%type;
    cus_Lname account_holder.Last_Name%type;
BEGIN
    SELECT First_Name, Last_Name INTO cus_Fname, cus_Lname
    FROM account_holder
    WHERE City = p_city;

    RAISE NOTICE '% %', cus_Fname, cus_Lname;
END
$$;
 H   DROP PROCEDURE public.search_by_city_name(IN p_city character varying);
       public          postgres    false            �            1255    25040 2   transfer_money(integer, integer, numeric, integer) 	   PROCEDURE       CREATE PROCEDURE public.transfer_money(IN acc1 integer, IN acc2 integer, IN bal numeric, IN user_password integer)
    LANGUAGE plpgsql
    AS $$
DECLARE
    source_account_balance numeric;
BEGIN
    -- Check if the password matches for the user initiating the transfer
    IF EXISTS (
        SELECT 1
        FROM account_holder
        WHERE Account_No = acc1
        AND password = user_password
    ) THEN
        -- Fetch the balance of the source account
        SELECT Balance INTO source_account_balance
        FROM Account
        WHERE Account_No = acc1;

        -- Ensure the source account has sufficient balance
        IF source_account_balance >= bal THEN
            -- Deduct the balance from the source account
            UPDATE Account SET Balance = Balance - bal WHERE Account_No = acc1;
            
            -- Add the balance to the destination account
            UPDATE Account SET Balance = Balance + bal WHERE Account_No = acc2;
        ELSE
            -- Raise an error if the source account balance is insufficient
            RAISE EXCEPTION 'Insufficient balance in the source account.';
        END IF;
    ELSE
        -- Raise an error if the password doesn't match
        RAISE EXCEPTION 'Authentication failed. Invalid password.';
    END IF;
END;
$$;
 r   DROP PROCEDURE public.transfer_money(IN acc1 integer, IN acc2 integer, IN bal numeric, IN user_password integer);
       public          postgres    false            �            1255    25041 )   withdraw_money(integer, numeric, integer) 	   PROCEDURE     �  CREATE PROCEDURE public.withdraw_money(IN acc integer, IN bal numeric, IN user_password integer)
    LANGUAGE plpgsql
    AS $$
DECLARE
    account_balance numeric;
BEGIN
    -- Check if the password matches for the user initiating the withdrawal
    IF EXISTS (
        SELECT 1
        FROM account_holder
        WHERE Account_No = acc
        AND password = user_password
    ) THEN
        -- Fetch the current balance of the account
        SELECT Balance INTO account_balance
        FROM Account
        WHERE Account_No = acc;

        -- Ensure the account has sufficient balance
        IF account_balance >= bal THEN
            -- Deduct the withdrawal amount from the account balance
            UPDATE Account SET Balance = Balance - bal WHERE Account_No = acc;
            
            -- Print a success message
            RAISE NOTICE 'Withdrawal successful. New balance: %', account_balance - bal;
        ELSE
            -- Print an error message if there's insufficient balance
            RAISE NOTICE 'Insufficient balance for withdrawal. Current balance: %', account_balance;
        END IF;
    ELSE
        -- Print an error message if the password doesn't match
        RAISE NOTICE 'Authentication failed. Invalid password.';
    END IF;
END;
$$;
 `   DROP PROCEDURE public.withdraw_money(IN acc integer, IN bal numeric, IN user_password integer);
       public          postgres    false            �            1259    17084    account    TABLE     }   CREATE TABLE public.account (
    account_no bigint NOT NULL,
    account_type character varying(50),
    balance numeric
);
    DROP TABLE public.account;
       public         heap    postgres    false            �            1259    17074    account_holder    TABLE       CREATE TABLE public.account_holder (
    account_no integer NOT NULL,
    first_name character varying(50),
    last_name character varying(50),
    phone_number bigint,
    address character varying(50),
    city character varying(10),
    password integer
);
 "   DROP TABLE public.account_holder;
       public         heap    postgres    false            �            1259    17079    branch    TABLE     �   CREATE TABLE public.branch (
    branch_id integer NOT NULL,
    branch_name character varying(50),
    address character varying(50)
);
    DROP TABLE public.branch;
       public         heap    postgres    false            �            1259    17096    fd    TABLE     �   CREATE TABLE public.fd (
    account_no bigint NOT NULL,
    first_name character varying(50),
    last_name character varying(50),
    amount integer,
    time_year integer,
    return_value numeric
);
    DROP TABLE public.fd;
       public         heap    postgres    false            �            1259    17144    loan    TABLE     �   CREATE TABLE public.loan (
    loan_id integer NOT NULL,
    account_no bigint,
    loan_type character varying(50),
    loan_amount numeric,
    interest_rate numeric,
    loan_status character varying(20)
);
    DROP TABLE public.loan;
       public         heap    postgres    false            �            1259    17143    loan_loan_id_seq    SEQUENCE     �   CREATE SEQUENCE public.loan_loan_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 '   DROP SEQUENCE public.loan_loan_id_seq;
       public          postgres    false    219            ,           0    0    loan_loan_id_seq    SEQUENCE OWNED BY     E   ALTER SEQUENCE public.loan_loan_id_seq OWNED BY public.loan.loan_id;
          public          postgres    false    218            �           2604    17147    loan loan_id    DEFAULT     l   ALTER TABLE ONLY public.loan ALTER COLUMN loan_id SET DEFAULT nextval('public.loan_loan_id_seq'::regclass);
 ;   ALTER TABLE public.loan ALTER COLUMN loan_id DROP DEFAULT;
       public          postgres    false    218    219    219            "          0    17084    account 
   TABLE DATA           D   COPY public.account (account_no, account_type, balance) FROM stdin;
    public          postgres    false    216   \L                  0    17074    account_holder 
   TABLE DATA           r   COPY public.account_holder (account_no, first_name, last_name, phone_number, address, city, password) FROM stdin;
    public          postgres    false    214   �M       !          0    17079    branch 
   TABLE DATA           A   COPY public.branch (branch_id, branch_name, address) FROM stdin;
    public          postgres    false    215   qR       #          0    17096    fd 
   TABLE DATA           `   COPY public.fd (account_no, first_name, last_name, amount, time_year, return_value) FROM stdin;
    public          postgres    false    217   �S       %          0    17144    loan 
   TABLE DATA           g   COPY public.loan (loan_id, account_no, loan_type, loan_amount, interest_rate, loan_status) FROM stdin;
    public          postgres    false    219   �S       -           0    0    loan_loan_id_seq    SEQUENCE SET     ?   SELECT pg_catalog.setval('public.loan_loan_id_seq', 20, true);
          public          postgres    false    218            �           2606    17090    account account_pkey 
   CONSTRAINT     Z   ALTER TABLE ONLY public.account
    ADD CONSTRAINT account_pkey PRIMARY KEY (account_no);
 >   ALTER TABLE ONLY public.account DROP CONSTRAINT account_pkey;
       public            postgres    false    216            �           2606    17078    account_holder bank_pkey 
   CONSTRAINT     ^   ALTER TABLE ONLY public.account_holder
    ADD CONSTRAINT bank_pkey PRIMARY KEY (account_no);
 B   ALTER TABLE ONLY public.account_holder DROP CONSTRAINT bank_pkey;
       public            postgres    false    214            �           2606    17083    branch branch_pkey 
   CONSTRAINT     W   ALTER TABLE ONLY public.branch
    ADD CONSTRAINT branch_pkey PRIMARY KEY (branch_id);
 <   ALTER TABLE ONLY public.branch DROP CONSTRAINT branch_pkey;
       public            postgres    false    215            �           2606    17102 
   fd fd_pkey 
   CONSTRAINT     P   ALTER TABLE ONLY public.fd
    ADD CONSTRAINT fd_pkey PRIMARY KEY (account_no);
 4   ALTER TABLE ONLY public.fd DROP CONSTRAINT fd_pkey;
       public            postgres    false    217            �           2606    17151    loan loan_pkey 
   CONSTRAINT     Q   ALTER TABLE ONLY public.loan
    ADD CONSTRAINT loan_pkey PRIMARY KEY (loan_id);
 8   ALTER TABLE ONLY public.loan DROP CONSTRAINT loan_pkey;
       public            postgres    false    219            �           2620    17136     account check_for_account_number    TRIGGER     �   CREATE TRIGGER check_for_account_number BEFORE DELETE ON public.account FOR EACH ROW EXECUTE FUNCTION public.check_account_number();
 9   DROP TRIGGER check_for_account_number ON public.account;
       public          postgres    false    235    216            �           2620    17131    account check_for_transfer    TRIGGER     �   CREATE TRIGGER check_for_transfer AFTER UPDATE ON public.account FOR EACH ROW EXECUTE FUNCTION public.check_transfer_balance();
 3   DROP TRIGGER check_for_transfer ON public.account;
       public          postgres    false    237    216            �           2620    17120    fd check_forfd    TRIGGER     p   CREATE TRIGGER check_forfd BEFORE INSERT ON public.fd FOR EACH ROW EXECUTE FUNCTION public.check_accounttype();
 '   DROP TRIGGER check_forfd ON public.fd;
       public          postgres    false    234    217            �           2606    17091    account account_account_no_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.account
    ADD CONSTRAINT account_account_no_fkey FOREIGN KEY (account_no) REFERENCES public.account_holder(account_no);
 I   ALTER TABLE ONLY public.account DROP CONSTRAINT account_account_no_fkey;
       public          postgres    false    214    3203    216            �           2606    17103    fd fd_account_no_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.fd
    ADD CONSTRAINT fd_account_no_fkey FOREIGN KEY (account_no) REFERENCES public.account_holder(account_no);
 ?   ALTER TABLE ONLY public.fd DROP CONSTRAINT fd_account_no_fkey;
       public          postgres    false    3203    214    217            �           2606    17152    loan loan_account_no_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.loan
    ADD CONSTRAINT loan_account_no_fkey FOREIGN KEY (account_no) REFERENCES public.account(account_no);
 C   ALTER TABLE ONLY public.loan DROP CONSTRAINT loan_account_no_fkey;
       public          postgres    false    216    3207    219            "   P  x�}��N1Eי������,�`��uSP[��tl'C�Fמ�\��'w���ۿ]���=�����r���ߎ��#�����q8���
A��m�o/Zw*''%����ir!�2�΋����zt�"]�՗��=&QB��!��R�>j-+���ڊr0�j=��xx08R���
�+�����'���Q�������ܵH�残��-�;a�΢��d��\4:�2g'�ȩuJm�)�֩�&I不�s7r�E��u^ENX\#����rd��F���ȱE����K
5riA!q�)�Ƴ��\�w:��<�e݋<�3<������0��          �  x����n�8���O��H�p�$�.��5, @��ac"�-S�b����pt��]`sa�I����aX2ة���E7'Y��R����"<+c���h}�uU�^�K�aa��1�
�R-�32~�c�h���=�R��D��s�O�?�^}L�#H�?W:��,��W�MUu�azǢ�b�]�
�����	�`k�v�������,J(�8��
c�Yd�z���OuuTÓE�Ca]��[9m!!�����4��Ͻn�/����!�������{����ܛ��˱m�za<� R���A���|�-M����U�s�@�`����U}�;�R�NtU�����1.]M�ZsY�"�8I	�!��b�TS��-�����Xv$
�jiW�o���ֿax2�R �q�x\F�BX�/볪�0�Q��0�*��T��花�A0:_���VyՌ8Us�
I���~����yCVB��1��a�$)���E�E!)������2�`�
v9,lA$t~���x�W��Ǝ���ה-R
"�sT�.vTv��R�	B�.de��˓񋘑��(zz�̝���ԧ�F�3_��I����$�e'8�N�N\U�$���嫁G��
+9HrH�(�~,y�7���.� �!�,~�!&�o�A�="4�NV��$5c1e<�c�F$�j��Ñ���|�,x����.�G���
^�DL��Y�����fz����#�`>�"f3��f8��H9���ZvQ�S� <�c�D�%?���`���Wy����EQ��ٮ�JtB���n�>���7�iଠN�#���#��h!���	Y$�S��z�ILL���N� ��'+i�x6qo�tB&��ϛ˺�)�sr�)Y�SG
�+^�O�[���l�q�E��wC�Vw'{�d�b�0.)��l8u�����|q)~+L��@�Q�7�l)Y� K�v��YȈ�7���|I���9b`��<��V���%u���y2�����$Y���)��p0��G����Ό\��S��"��c�|�0�L��1�j���ׇ�u|vi���!����*wo�*��t�rk�� !��~�2�.�3Id��D�֥��Z�����x0��SU�l�Z)��B���8��y=B����]��z����?6��?`      !     x�]��n�0���S�	�$M�);L['���v1MD��)�������-�~�����8|�vO5�\e��'wg��9��j�ښA,���/��ЦP�;������|�s�_�G����΍�a�Kr��m�L�Z0�S�E����x�*�iO�/JY�s�[KUtY�6�a�$�����2��i�7�X�s���W6֬���c���R������9Uț!Ry�hF�тs(Cո���!q���r��d{q.F�V���i|c�BY�{5Lp�n�+�|���$I�мk      #      x������ � �      %     x�e��n� E������X��V����j�������\&t�w�C2)�d縬s^��1��N��2��W�����l�8E�����A��.�4q��g��6W@�
��ɐ���^S\��.f�������r�7�� ѳ�z�c�1 �w�Y����Η�RD�2���BQs�V��AE}�ZF�(%B���j�Rؽ
�5[7z:�hA��#�@� �����KI�@��t�M�׽9W�=��
��ڛ��`|_0�o)pӟ����ֱ�!@�NC�]�8�S0��     