(cat > composer.sh; chmod +x composer.sh; exec bash composer.sh)
#!/bin/bash
set -ev

# Get the current directory.
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Get the full path to this script.
SOURCE="${DIR}/composer.sh"

# Create a work directory for extracting files into.
WORKDIR="$(pwd)/composer-data"
rm -rf "${WORKDIR}" && mkdir -p "${WORKDIR}"
cd "${WORKDIR}"

# Find the PAYLOAD: marker in this script.
PAYLOAD_LINE=$(grep -a -n '^PAYLOAD:$' "${SOURCE}" | cut -d ':' -f 1)
echo PAYLOAD_LINE=${PAYLOAD_LINE}

# Find and extract the payload in this script.
PAYLOAD_START=$((PAYLOAD_LINE + 1))
echo PAYLOAD_START=${PAYLOAD_START}
tail -n +${PAYLOAD_START} "${SOURCE}" | tar -xzf -

# Pull the latest Docker images from Docker Hub.
docker-compose pull
docker pull hyperledger/fabric-ccenv:x86_64-1.0.0-alpha

# Kill and remove any running Docker containers.
docker-compose -p composer kill
docker-compose -p composer down --remove-orphans

# Kill any other Docker containers.
docker ps -aq | xargs docker rm -f

# Start all Docker containers.
docker-compose -p composer up -d

# Wait for the Docker containers to start and initialize.
sleep 10

# Create the channel on peer0.
docker exec peer0 peer channel create -o orderer0:7050 -c mychannel -f /etc/hyperledger/configtx/mychannel.tx

# Join peer0 to the channel.
docker exec peer0 peer channel join -b mychannel.block

# Fetch the channel block on peer1.
docker exec peer1 peer channel fetch -o orderer0:7050 -c mychannel

# Join peer1 to the channel.
docker exec peer1 peer channel join -b mychannel.block

# Open the playground in a web browser.
case "$(uname)" in 
"Darwin") open http://localhost:8080
          ;;
"Linux")  if [ -n "$BROWSER" ] ; then
	       	        $BROWSER http://localhost:8080
	        elif    which xdg-open > /dev/null ; then
	                xdg-open http://localhost:8080
          elif  	which gnome-open > /dev/null ; then
	                gnome-open http://localhost:8080
          #elif other types blah blah
	        else   
    	            echo "Could not detect web browser to use - please launch Composer Playground URL using your chosen browser ie: <browser executable name> http://localhost:8080 or set your BROWSER variable to the browser launcher in your PATH"
	        fi
          ;;
*)        echo "Playground not launched - this OS is currently not supported "
          ;;
esac

# Exit; this is required as the payload immediately follows.
exit 0
PAYLOAD:
� J�Y �]Ys�:�g�
j^��xߺ��F���6�`��R�ٌ���c Ig�tB:��[�/�$!�:���Q����u|���`�_>H�&�W�&���;|Aq��_�*�Q#�/5�s���lm��ڗujo����^����}$����n����^O�e�!#�r�S4�W�/���6���p��1���J�e���?�x�:�\�(I�������{�+��[G���'�j���_����g�8�_�˟�i�������t�eؙ.�t���)�����k��GcAQ����:�ԞG���럕{-�����4B�����yNٔK�(M�(M�Iظ�E����OS$����Q����O�7�g��
?G�?��xQ��$�X����/5��������ؐ՚�}P��	���S�4]h�(�H��&��I����V���l5�M[�Ta&��~ʧ1�<�j���@.6�&h!�S�J�MJO��<�Mt��h�C����@O�{<e��t�����24H���ֶޗ�.��P�Ȗ(z9�����tj��
/=���ѿ)~i��^4]�~���cx��GaT��W
>J�wWǷ׉=��+�%p��'�J�����uC�d�P���_������� �9ʚ���d���̐�Ys)n[D� m.W�����4̸PѲ�5K05�!�-sp��@"�)m�2{8޺�X�8T8���u�IY�!kH��:s�� ���"�s����� �D��P59�|�[�G���;�#F�`��"(�r�,D1�`�E��W�i�%���-�(�i*;� t�\sh�su�4���6�P�I308繆`yS��F���c�[q ~�,]̅��/��O����xk��X��?�&��B�7�D��bD(m����|7�Ȕ�	Ӱ��X�1je�>�����f9+�d�r�v���,7Gq�;S��kQ�с�@��r��sM<�<��ީ������B���J�υ%(��}��t9^eu�Ș��6|#;��a��l�E�$m.o4F�t�4W���%�(‗5����e�Ob`���1f��:���a�����w�\��$mIm45Q�u�!�%�H�X4�9����l���̆g������6�@������|���?�^��)�c(AU�_^�qV�����#ü�ީ��.Yo	$��-����9ǉP�1�%�
��Q�N����٩pP��*�*Hv�Vp?�+3�>M�� ��,,LCѕ�&�,�`w�8b�N��(��K���s԰�D�/['RS�w�йY��f�Ǧ�{E��bn5o;�p��;P �{�-C���O�e虻l�S�r!<QuhM���ãr����)gF���Y ���@��O��8^���X{x�gB��Z���C]��;����6%�|�H�9��A�A�9lQ��Qt�f��LH��5>�8�hQ�y��k�_
r���M��X����sS��gr]K���m3�>�P�0Y����O�K�ߵ������IV���C��3���{��*�K��%���+�����\{����c/���#�*�/�$�ό���RP��T�?�>�I���D1�(�-�N�S$[�:ASv@ ,и�`.�P�.J(F�GzU��߅2�������������pA�����IA+G�	�2�x���
� 4.�7�|x1�g-[�m[����r�45~��Ko�R��d3D��/9��g�A�ۑ���s���W����v+�j� �n���iX����4�?1�����K�G�����J���j��Z�������w��O����������������R����=��f�GB��
Sz��Ђ���?�}0���C�f	����>�.to;M�w��q���G&]���dR�M��5�{&h�����Ρ"�1�+�0�C����ٰ�L�[��(�cД(�𸘠KnP�dՎ�cx�h]c��-���1"�H������ N4�Y8e�!9H϶�"�0y�J�^;w�	�)��P�&+����Q^p�ߙ�8>Z���ɠ	U��"�}�c�+~>4��~-&!oם�6;���gJ�Һ���r�c�����N�H�G2g)���:��9O�
�$+��V<�?�/��ό��*�/"�ψ����T���W���k�Y����� ���Q���\"�Wh�E\���������+��������!���Z� U�_���=�&�p�Q��Ѐ�	�`h׷4�0�u=7pgX%a	�gQ�%Iʮ��~?�!������+��\��2aW�W���X�plNl����{���6[�A�z�^��C	��yܩ�JJ�E�Il/��j����hc7�1c���������<D i�l0h�C���<�甒S�ݬ��{7��8���Ï����Gi�Z�/o����w�����:��\(��ח)���t5�K�{�� ������r��8�V�/)����^,E�j�o)���b�?Y�!i�Z�)�2�Y���ň��ǶI��)�B]�B<�`Y�����w]7��%� p|�eX��JC�|�G��?U�?�������Aj�h�(��P�A����0�.���]#M���/���4���v]wW����s)���aDn5f����Q�5#���n��������j=qMP��	ff�^���9�_�����*����JO�?
�+��|���}i�P�2Q��_����b�c�O X�������1��㿟��9+9�Vᯱ�% ��7�g�?�g}��$������7����*-û���֍��{�� �7�ݰ����s��Mk?lڹe�@��S���)�b^<�]h�i���Mb�ڷ�M�	l#ע�iV��X�g�����z�N��7o�(6W3����V\4�ߛ��
�[g���|�G�-ãe�q�#=�$l��v�$�\h���@8ǻ5u�\�(R�&���t�*�)�sj�N%��ǆĭ�0����@ u�3"�mo�ey����A�Ě@�D0�ljN�����|sO���F���4�r�Yf<%���?m{�ȡ��<wJl���'�M�V������Z���"k�JC�y�`��_����+����?�W��߄ϙ�?ȭ܀�e��U����O%���K�������� ���5��͝dv�
9���D����P�'������7��6��u���>�=n�C�j
��k���m����=8"1��C�MIiK[TwDck6�^�͵F߲���m{���L�ص4�aH���dNS�28�PеDr��8�I�� ��B��<���]j�?6�Y�|�9���f-x6���nڷW�`�5��\��^J�r��{���,�C��z}��{���46a�Dw�h�"���������_:�r���*����?�,����S>c�W����!���������?����_��W��o���:�b�ð�������ܺ���1
����RP��������[��P�������J���Ox�M���(�8�.C�F��O�L�8��C�O��#��b��`xu
�o�2�������_H�Z�)��J˔l99�[�Ԍa��"4����V�X�<�-j���c�鸭��+�{ɚ�zb��vp�*�(�9����Q���w-���3�(C�Sez��RGYl�C�j��{����O��%q�_�������-f���_����l�4+����_�_���v���W�Vsm�x�զ��_k�}�����N:u�\�뎡n(�
�F��+{�L��g��v����_�ϕ�jW5	p������U�o��v��zul���>���:�^ǿh�$����V��^z_k٤v���zZG�(�u��H�>�VӅ_{��O�C���q�h��/��NΫ]9������I�W��;u�6^l"�A]×�����Oq��˵=]���Ҏ�Q��7w�AE�[[�v�<-|��ʰ�-v���ꂨ��MCTEtn:r�U ���C�O?/�>^�r_�fW�v��kE%��|��^�q������\;�BϾ��.:J�'ߺ�o^--���DYrg��X����}�u��Y�E���K�2iA���^ܛ������Ӻ8�?��n���6��5x���ߟWe���?��ǒ߿���4����NM��t>]�7�4�Z��d�qb�'p��p8]O6�u��~0�I�^�=L|�	�!�#%pVϧ�� }T�#����Gdq�S7�X=��^��2)���7|�*��q$�C4dE��o��y\VGƷu��'�J1g�^WV�o��t���I��᭝��f	�-����D�{W�U������\z;u�r;���[tgo��p
�:N�d'q�����q;�{�|WH$�T$`�"� @� �/@��~�VBˇ�Bh�-Z	�;�'�$3�����+�q��|��}����sαrf�Po�i���%Xl:��&6�\�%��6�B�,�NщX���WÃ�tE�X:�Kdn���d��ֶ�3P�<I�����`_F�)2iwݱ��ӢĢ[��4У@��ׄ�c2/�bnrN(�����ՕEW]Uu ��e�ݮ��tM� C#Ԛxh�K�X�hv)� `-���5a�����G����j�M���cS�4g���̰ztI�#i���O�����/��-���[5�����+ĻE�3o��1�`毙gnN��zhN#��[T)�7���Ѷ�������)�PZ����UGM��N͸=t��l/j���z4���h�
C^�h����;�������g����p�}Ep:;1�Ӏ՝�#Z����� vv����#IW{�ڪ�~��������)�Nk��{Nj��/ltSi6�6aq������;�i���rû숂��]5_���PFV&:�t^3��?��ǣ5��fVa
���E[Y\}8-��B�i�}l�2��"�����L)��m�~�cr]�	EnZ��j���������ϒP��W[�В���^��#׎��B����͖tM�pc�Q��;��<8r�@#�O�*�=��X��֑��2�1pYB�N�8�e���ے�e���i]<�F��M�����R-vF�U{M6|e�*������.l}��>G�����]����Og�V��l�4��^_!8<��7h�����ժ���?^���g��n���|�y��E<J[v.m��O���]�{l����>V�=>O=���C<��ǃ�`��~^�C�߷��=pT 5�'1�'����hz��շw_z�����������_n=��D~���pX����np�4�|ݍ��a ����|�x�y��5�א�][����'�Â��}v��� ^ܕ��ts��7��<0!瑃�,�ؼ0`���oR�$^뜴x�I���� BaFV�����C���a!� �v�U�һt�&RU����85��^�,�Խ��J]�]��:(��@V��A4�,],��8�k���}�6sK�d�$�Q$os��[���"����0*0�Va�h|@Ȇ8̲y6<�.1�*l�'g«d�1����R$�͏�Z���)K:�T��F3_0R�U)�j���zGJHi�ȣᴁJ)c���*��ň��=��i��Y�0dU+Ǒ��/_r���a�nE�|"��GL�e�E��ܦ�a�M=�)�5?��f����Ss#dݫG��F<���1/��Nz��P.��w��~Uh&Uth$1P�Ź0^(Ҹ�vZ�5О��r.J�[�h1�� ��!+͍{\�V3(�A� ��r<��)t	Y�/�N�,!+ً������dCu���U�b�ˍr5���@���O6�$�r��j��P��B=�N���~*Y�Ԓ�q��		.v�6����D�IY�l���,{��n�?�%�ZI�Q�x��Z��c	+�^rB'-�{�x��:�Z�%ʙ��f¥$#{�Z'c
UmT�}�t�Br
[4�
c��L0,��"��(�%e9"� �VY⺏��C<Ӕ�l�ī��A����y_4�fe��e4�������{XXgұF+��jqP����DJ
u�"��VY��e�BY��+Kse�㉁�1�W�8M{�<�R�<���؛�zc�]�/~4�eE�C��ң�/�{�nj\���dK8��Q,���PS��)KTN7��(F�q=TUA��2�l�*pؒ�^�]�,\d���8���Ɛ�*����Q�����SR��Oy��n	p�nK�Tzh�u�K)ŀ����X>-��6Jy}�r���,n�gs|6�g��g۹D�?Í��Kz�+��.��֝���\�/lݱsy�������G��e�>�g�2�g�����"_;UU;� o�]A6C�j��܏����=m�y\�t���Q��0B@���� j]RQ&'wP��BV4�z���a [sU�K�3b����&"��%p�P�q�{���cyryl?�̷���<�o�mw�U��֛0��}������"�4jVˑ�"�B�{��1W��m���ļ��)�+��up��4��
����1+V��)��A�� �����@��U �]V$}������D��?���y��6�ۇ�9/�K��/ϝ8tOL���Қ�Z�(��P������KJ�𠭎����h.:�Ok��xX���6]p�rd����κ��U��4�5gс<8�,DJLE�>���ޘ�UZ�2��}|L#b���\(+��VpLu�X<���0��h�/��R��Q��*E���t�MB%�,��5��Y��؃�a�If�d1A��2���19}3�Y����p�D4�j(��A��{��\||@�=�NjL�\�@s�D�#�@V,�	Ez@-������*�G}X��|�i����x82�x/$�AB
wd}�f0���P�vK��B���j4��8.5�� ��c����c�q���z��G��A��s��e��:&�9f>ӆ90۳{y
>8��^䲝���yX�=,����x�x�{[<,'��Ɖ�m:���#|����j�ԅ4o~~D,)����9,Py����6��A�YL�5(2k�E�5gY���0�ryg�����"�v��#tX�c���݌!�O�ZG���zBɪ֧�V�`�����qt4�h��Q0&!E��`��X8m0�0B���E��}��b���q߁��p����'U�w1\Ԇ����E���rU�zcR�)�~%S#Ӣ.U�1��R3�ǃ(��������!��-x ��ӢQmV
�~��&=�f���]�yc�1�8�ތ�Tޏw1ⷑS�=�S��c���F!��l;7��V�.�w�8oȍ����=��ӭh��_`�oN|{�$k5]4р�v�w��k�_��BIER�-�mA���\����ܨWY���M���"r��vso���ˏ�����z?����/~��{��^��s~r��ou���k�ws�bZ9Q���8��������9��ے�{��կ�׷�b�/���7�a���O&x�3����d�k�w�_D�=	��_L� xp�N�~hqE/wEc2��QCv���K~���������Cy�?�}�ŗ�����y�7x�A~� ���v�̍��H���C�t���ӡ	84���|�}��u�N@ڡv:�N����l���z�v��oy��7NA�܄W)3���M�m�@޶�:�x��s���31t���!~�:��5���8n��3p>�:�R��c�q�f<�3p$���d��zin��:O˙3�D[�93δ gZ�3g�1�8nÜ�3��=���13��y��NZ۔���Gϑ�y^�R�����Nr�����m�+yg��  