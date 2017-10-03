ME=`basename "$0"`
if [ "${ME}" = "install-hlfv1-unstable.sh" ]; then
  echo "Please re-run as >   cat install-hlfv1-unstable.sh | bash"
  exit 1
fi
(cat > composer.sh; chmod +x composer.sh; exec bash composer.sh)
#!/bin/bash
set -e

# Docker stop function
function stop()
{
P1=$(docker ps -q)
if [ "${P1}" != "" ]; then
  echo "Killing all running containers"  &2> /dev/null
  docker kill ${P1}
fi

P2=$(docker ps -aq)
if [ "${P2}" != "" ]; then
  echo "Removing all containers"  &2> /dev/null
  docker rm ${P2} -f
fi
}

if [ "$1" == "stop" ]; then
 echo "Stopping all Docker containers" >&2
 stop
 exit 0
fi

# Get the current directory.
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Get the full path to this script.
SOURCE="${DIR}/composer.sh"

# Create a work directory for extracting files into.
WORKDIR="$(pwd)/composer-data-unstable"
rm -rf "${WORKDIR}" && mkdir -p "${WORKDIR}"
cd "${WORKDIR}"

# Find the PAYLOAD: marker in this script.
PAYLOAD_LINE=$(grep -a -n '^PAYLOAD:$' "${SOURCE}" | cut -d ':' -f 1)
echo PAYLOAD_LINE=${PAYLOAD_LINE}

# Find and extract the payload in this script.
PAYLOAD_START=$((PAYLOAD_LINE + 1))
echo PAYLOAD_START=${PAYLOAD_START}
tail -n +${PAYLOAD_START} "${SOURCE}" | tar -xzf -

# stop all the docker containers
stop



# run the fabric-dev-scripts to get a running fabric
./fabric-dev-servers/downloadFabric.sh
./fabric-dev-servers/startFabric.sh
./fabric-dev-servers/createComposerProfile.sh

# pull and tage the correct image for the installer
docker pull hyperledger/composer-playground:unstable
docker tag hyperledger/composer-playground:unstable hyperledger/composer-playground:latest


# Start all composer
docker-compose -p composer -f docker-compose-playground.yml up -d
# copy over pre-imported admin credentials
cd fabric-dev-servers/fabric-scripts/hlfv1/composer/creds
docker exec composer mkdir /home/composer/.composer-credentials
tar -cv * | docker exec -i composer tar x -C /home/composer/.composer-credentials

# Wait for playground to start
sleep 5

# Kill and remove any running Docker containers.
##docker-compose -p composer kill
##docker-compose -p composer down --remove-orphans

# Kill any other Docker containers.
##docker ps -aq | xargs docker rm -f

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

echo
echo "--------------------------------------------------------------------------------------"
echo "Hyperledger Fabric and Hyperledger Composer installed, and Composer Playground launched"
echo "Please use 'composer.sh' to re-start, and 'composer.sh stop' to shutdown all the Fabric and Composer docker images"

# Exit; this is required as the payload immediately follows.
exit 0
PAYLOAD:
� ���Y �=�r�Hv��d3A�IJ��&��;ckl� �����*Z"%^$Y���&�$!�hR��[�����7�y�w���x/�%�3c��l�>};�n�>԰�DV@ŭ6�Q�m�^�®�{-����@ ���pL��S�B���r$� Fä���BpmZ <r,����x˞�J��,[��6x&=�8Y]E�6���M>�o�uYL�B�ç�ނuR�赑e ������K1�6��#	@ <���m��+CfG���B�3@J���҇�A!��n�� \?Q�Uhi6��N����5�@�2�a�SB�ė�\2��	��"d)ZK7��iaà+#�B�X8��өE�H%��4��ݤ1ـ��w.���O��i�7L�:d�-\��x�M�FV-]]4|٪��oA�����:bPXD�!U��:�"�&�C��`�����l
�,�FVQ����]���K�9,�!����5�?�CZ�eЮ׭��
�������#؎	a��S��g��P=���&jP��V�n�R�΁U���E��b�e8����&�Wa��㗗�Ȁ?gԟ?usd�l�{Z_}t����ǖ�Rf�t�i�a�R2��N����60]ø��Q�s&r��j2���t�z�Y&4�d�v}�q��m�?x8��N�§�{o�:y�Xd��Ga��IQR.��|"�ޓ���3��Ač�]ӳ�A�q�6��G毿(It�#aY�D��L����J��w��n���np6v-��s�j쟦[Tc��W	����|pTJ��
��<����߃vW#�B��A��֥�F�!�T��r~V��������e��oC�	�(xnc�^�`����?Q"S�]���t7�י�m �N�x!(#^���2��eVf:��sdj�"{�2p����v@۵���o�m��Ю9��X���s��Vox0<�뎿�?�Ɇ�<i�U���<�t06� ����R�N[�gNI���?CW�i��"5���(z�Dv��h�Ϗ5<�e��jSm��ocåjӎ�����L�Vuvx5�7��h��nhh���p��k�A @��c9��8D�|�FK"u��Q���ƃ��V�_��#1(��Gd��'�'�:�F�D����d|>X��S#����\��I����Q���0��qO ��@�5�a>p�M�0 45`�� R��嚦n�G/�lnX�vp��&w�q�����c!жA��&���[�M�ă�n�<x���4�*@j~��GiC���vx ��~!°!�\�o���Q�j:i\�l��.�m�D9h�&�Z-��@��ۧ��N �5����]DHg�Casv8괏���-�WoQ�u��{2��A{2?6v���ynb���e�)���&�SA �Mq6������ѥ蓘�Ohw����i����\��V��]��c�i���p��rx�?4����Tt�� �y6�G�s�G{�9cN�=`��x���s����M�'�3�n�e�	���l�^�NxoTi�O��({��M&N� �Z6_�!N�<D�����
�k]�_�l�r6���0��SF���
�?��Fb������?_6̐��Z�SK�_��ش�����Հ�'�F�0�w�-�3��Ӯu�,l��v��zN�kY�����V�K�J;��N��n����,�+;?݄�j���ٕ�����Wc��g�K�Y\/7�$J���t��;(����f��@ �\�F�K��n�6����&+��QE2l4�&�H�ϞN>"��;���-W�R�C%�OU��zmV��xn#�X��ym�wĈ7�Zh�ٟ�
���OYT��w��[�tf�;O-޿�-	s.�vu�+�鶪�����K��[
DZ��ɒ�NO��?�����������?����"��1b3��Jv������X�[��[������e������� .���(L��pl-������ɧz}O�v�&Y� �@�B5��8!<�o��Z��0C�������L����������?W �ן�p���^�Fp��+����]�����������ѵ�_	L��M�]86�ܲ�,[/A��M�!�jAS��݁P�Z{��w],�~r-�)�����.3���ϋO���|LDȖ����1���]�,����jdDz���EF������tp+jS%�r��t�Fȴ���c�4�B�I9�{b�@���?��3ު#�ۄ���aO!�n̄~k�E�XC`�2A<�Ιj�3�;%N�`�t��TAs�r����.A���L�>�	������w���L>R��B���!"�{����Q)�큧ׂ� ����9�^{�f  ���_���V�ٹM�������ЪU��M��.A��?"G��_�������qY,cK�7Pv��B?�'�����Q���J7����Z���9^����*������n�lwf�O�T��l���O��s@F���2�p�&�.��Q���@H�s+ю0Ip�� �����i}�P%�����6z�.zqSwiƳ��LQr�]���l?����%�A�IC���):&���K0��gi&?�ČS��ffΘh}:YƬ��raLu*��ӫ݃|��0����)�r����Â�s}���%3��Ҁ�@��"��HmxV2��{5c��
���Í��@�}B�?�c��>�_�z�GJ�SOA�bYt���"���HD^������������o��������_��0e~�	���*�R|����(�a�Z�խx<Z��%Y�A$�H���j<,�P�G�q�ۊHխHd�?����57MxC��W��v�Љ�B�n�y�x��S�Kb�Ɩ������'nc`�F����W�j�ȿ��W#:<���庳7�e����7���d��'��7'ټZ��6�����6��8?��o��Ͻ��^���{�6n����Z��>q���&o���/]_9*���p����ҭ�����Nc����$}���?��K�����S�N���W����9[�m|�AEª�b�jMPc[aa��G5U�n�qY
#��-
jXT(n�`�*� �CY��H����"�Vk�
��($��\$ӥJ.�K*�4+}g�s�d�<�T�d]��J=WR
�y\x��B�l���8�4��d�4���r��B��v���>��4��x�N4�����E�R)%�cB��lլѪ�_��$}�9W��gj%uL���;Sme�Sɸ<��.�升�+�l�wv�v��4�7	��9�J��nJ�N���
�w�~k&fw����[8�I�JN8��Zv�ʄA�;��<Q��n�x�:.������t%O&��.�����O�:j+�>��O�7�|�y$e�\��wz9�o
���t-����OJ<�(d.�|9b�l�Q��~�ЩVgd&�l��1[��q���&���nzWrJ"�n�]$�b�yQ���~'Vx��G�h���I��:�k�7O�cF�v
����ʺ���bg�nj�P���vX����^���;�T�yE&kAz����D�[�k�[O)y:׻�|B�m��sE�'m:*-�-6��=%�hYgЍ%r��;�*�7�{�����<8��d&�ץב]��n^�Ñ�L*B]ɧ���bR����wf2]�X��"y^�#'�P�<{K�"�l�u�㝤�����^�
�{��t�s�|<�ߙo��P�{I9�h������d,�.�f������`�}l��u��@:fL�3[?�_�ܐC_@�(����@������0v�-{�+�O��w�����s�}+Z�%�������(F��+�1?鰔;&��OY�c.�����,�щ�Ѕԇ*낐���'�����j�1wv�e�*dO�cdRH�,�M�m�+�(%����G�R;Լ��d����J�E�s�q�W,Ez���"GǻRV�''��n�@BT�P�����v+j�D��������]���_�2�|��G�����[��C_ã_���f��u�ϕ���?J����?�즻����GR)�BRJQM�JƺV:�:������I��"z]o��V�1�2g�|3�T�t��=Δ��|��������L�+��z�B���z%SJ}gg܀O��s��o>A�{m����^��~%l��G��G�u���������"s�<�f��@1P�e6(!�Z�{B�,So�^�ۀw�[ӑ�F�o	A�j���t`�m@
�tSgS�F����_�i��	�4���L��/�٥��П��_┞������Q �p��6��b���6�ȗ�He�XF��tA��B���1���X��������v��x�����3�`�7�b�� ,<��C�o]|P�e�G�;����`�LdK�h��t4�$�LX5�����;����1���4���k��<C�Z��� �	�?^h�.��؅&˥D�@��z�I�G��ÆM/ B@˂=� -$�r,لv�؀QY��m�K��b@L�����dJ� x^B]�l/6A����~a��(/�M���J=8F'I��o<?`*��/�@y�x4��p1�y,]CT�	N��,��%z�_{魎>Ix{b�u���o'���B"~n�*��@�'sہ�KX�p�u��yH�^��C�����K`!�M���^��X{L�N�~cR���E1z�'%sb~����8��b;2�M�k�
��`�S�EV	��.U�5�����@N��wG��'�HE��-�vi���a��Q��e��d��2�.%�M�Wo"/P��4ޫ%PœĮ��۝b���H.i/�Lq�������K�j7�W�2_�� �����O��P�]���U���U�>��5�N�`��Fv��S�tbhR��tB�RQ�&RDt�`l��b����U��ɚ��u�)motL/W�D\6��h�9Ti�]}H�u^ņ����s*:x˶�e��N�6�F"C��!K��9�L�>���⃉ӑ�r�?}*Jm+��J�����PӘ�}���bl�Gl�S�d���udmُ�,lc��_�����?*I��޵�:�������"5��`�P�t��T���I.SR۱�87��y��rb'q�<n��I�X �h����;$f�����A,X �X���#�㾫rk�9��u�}�����������<~%��~��?��)��'M��t������?�������>�|�#�Ñ�G�?x��[G?�X���k�bB�?�,L��!Y�0)�#TD�3�4�S(�x8F�[1�TȨ�ٖ�1BY��D3�(����?|9���O�8������?���/�>��q��0�X�w��?����B�ꁿy?���wl��^��9@��}��=D�&����a��"?������p1��
 -�\�X�M7s�h�|lh�XJ!�^�dX���tλ�^._(�t�Ytr[x��B|誆����]��Uŵfd#��X'�)�;#�$Ll�]҄Ыυ^�z�z����g����%��hu��*�PL�ϙc�^���آ9кB�n&h�.ř�h!�)��� ;nٙP�	f8��5��<3���U�l&��:3��i&;0�p�l�^"wg��A5�/8Ug�h������ș�.�Au�A�x^����v�2;�tM1�D.]�S��&�]&�Y	?7gJ�X���dWʶ�f���E,OR(C[k�I:
cik~��D���6Yf��e�г%=���B��;�NR2���uR��ME�\: �4ivGajV�k�E�>췻���&F�-ZUi�_Lz�V�L]�:���cQ�\��259��q]n���ifډ�ɚ�*��4���F�N��lܤ����ON��"rH�-D+z	]��o���?���D�
�DD�
�DD�
�DD�
�DD�
�DDv./a�]��R�&o��$���+���s�nV�b��-q*�m`Z1>\l��^�Ί�BUNΗ�=wQ=x(��V=�=�S=Q3e5� ���X3u;������m/��t����44g��qφ5Ҩ��Vo���(VM}�):!�Ҵz�`j���nMM��k��͑�&���q��M�O�1���q:�$$V河e-G�Z8������[���P�pn^�~2tj��pd�%b���d�4s:Sf�İ^���2�Q���y����3V˦���%s��*7ʹI+��X����v;>�E�w	�y�P��׷�p�z���Q�-��7�^{�6���X^lu���%�{c�+���y/n߂��M��9̏4��|x��k�#��>@�|��uj����_��Y}y3�F�5������Q�{����#W���x������?x��C�=x�W����e�������D]e�Lu��"�%�[[:__��O�t���qb��[f�,,g����Bnc5��t%r��/�[tL��.�ؔ�5�)�8���BA��Ri��e�3+�!0�	𘅐j�Rf�'R�)����8�$z$F���٩��� ��Ա:����ۢ������q�4�0�G��em�HwT~�����D:gK�(��P-KuW"i�r�L�΁�i����F��0M�B҂�v
*g�&���vT��N�+Ǒ�!%G��/�z�4�Vi��_ҧȚ��dS4�p�J�5e��גM\��
��J-��r����&Z����B,#�#4s��lG��P�5�1f�|/F[����ɂ�t�����J��C��ʅz��� L3.���i���������û�?�i '�t�5��A���G��*&\cE.$��E��-�l��F�3�~�z��J�˸�ܖ�]vG��ߣ�N�,�/�oV�i!y=�����thٓ]�&�Ƭ#i�L��'uq��4��pXR���_U�R]&�la��h��A#�[������Q5�룍,M���٬��;T�B�iʜm(��6Omf�1�ɏ�Nu0�Q���Dj>�h��q��=?��tB��L���t�ɴ���KV��ߥizڪE�J�QQҩj_,�c.]���j��@:o\j^,��tX1M���~<��\�n����J�.�Oc8F��9����g7����J�Ȋ@�,V�D����F�c2rW
	[V��d��HFf�v�<�ڏr�#!iBe����U&���T�H�v�U&E`λ
��y�V(��0T(WZ���Ni�<���S�:�b.���\\��U":kJ|������4:V�gQ�12x����Q��i��t�"�ew4�m
�j�
%R�����1S8.MI����,t�34U �{
1o��/����!y=��݌Z�2x'�&��'�J�n�t����� 	k��ұ��d�2*1fi^ǦҠi
57
K���lX[��F�+�X-�]�L�]Z٥���e>�٥���n^!³�_&�2��]ȳ�	y�آEE7&��U,p�f|���ς�\e�Ouq1Vo!o�#m�ey��#�nI]*��o!�?���y���-��G�%����A�<;|�|��0*��ʶ��x���7�+�Rx��1� %� d-�uFVE�0�Gdz�|��<+�S�?qN'p���J_����gqhY�(���2����>�?�C�^�E�eV������.��� �Ș_����0*���!�����^�h��^p�����Q�'AVm��wr��z��!���_v���;��Hw�a2�J҃ci"���q�!�w �i��=.gD�	����sdl����~�����������FU�kr~t�z� ��OW�=�[�g��"�[����E�U��Ui����8�Ѯ���j�����zz���,�.ِ���~x4.���6��Bz��GKZ�q���6b`�`m�OX�eq@�L btE�.T�e���4��@hgXＱIàe1�:�uA���\:	y#�wGSMKg�A`�S�
�_���՜���/��Wh5��Y-L|H8�4�?����w�п Μ����Egz�c�����[[�>�@P�*�2������Y����j�Y �@�X+�E�OZQ=�zUX��UX���ŶB�dG�KF���X[�Y��2����ڥ!t��|E���D���!ˀ��6`��e2.<���In%�m���Ö:���`qd�(p��բv�Wr9�|��B���?V6g}a{��u]�a�a�;��k�#���U �v]l*t�뒟% �<��	^ ��t�z�X��c�z:t�%> ����B�4XZ�z�.�dp��!��}�S,��̡̍��l�	�l�P8�@R��/O�pq��eW׀��5�^D����l����eu�.6����'JZ�J�D� �uep�mc[J� �T��(��Ap�`�8�$��Tro_@�����I�f_ưJ�@���\�1��>�K��d�N�&�@�mo˽�'��6�nw�)F�9ư�+ �
�1�)� �A{䢶�
��MP��?9	�z�� �Y0����X]��`m�3 	�^U�X�(�<(�e��ف4W����j��d`�g}���M�;�� d��ݴ�yj�v�,�0�I���}��n��G�����@ 땉*iְ�UW{�qNV�NñhP`���C�\l����{�����ǖ�7n�Kq�b�m�W�վ�"D�[�j1����Jֺm[͇7�Մ�8<uf��ɉ�ef2��`uXSuH�0O�i��5��cVǕ��(�������~82�m��1����s�b�JR�/�9������hwH[h�Ά�P�NPp����:����C�0G��#7�-�.7ԀO��GH>Źu��!?޵#|Y���5|_�?7>��qseW��'#�f�O2���H`�!C|B|� �Ԗm�숹a�JL���@f߆gu�:A3E>~��@d�g�b�Н�94��`�+V�"�-K[U��,��e��ǳ��F�]�z�O��٧c劆N���ڑB��!�j��$#1B�Ȑ"��n��6.Gڸ$͐�����f;FI�pT�J:��� j�w��1��b�Y�ϜX>�U�>i?��m��XO���!�Ŏ�&̮��,nV%��)5�M,�"�$�naRL�$�
ǔ��JHj� ���f2S��(I�&&��i��9�?�f���	���e��t=Eo�wnI��uG�,���̾'�������;���x��1x!��,W��:�e�"�9����e��Jsڹ8_�,ͲE�Tz�A�
�07��ėNL��g�������=�����%�������g�㱫r�HW[]�c�����*���vdg28�AGc����OZhG5��&����ZgZ�A�F[F{߸��m��&Sw�ֲ������C0ۭnΐ������~�a��$���Bz�� �$�M��9��A��}<E��x�]�y��rr=kE8�l>�g�gӡ:?AQܳFg��L��m�T��',	?�(���#^��.�Mx���76?���r%1��&��Y����`���Fg�K�덮��} ���zjמ���6π{̲Z�MZeK"-r�O�i�.q�� �)�\�?�+�S,���˝ 7b*��_(�z~[<=
�<qfޙ|֖4]�����E��`б���#��u��;�_C���Yt7�����u�e�Џ�n�_��ee�e�l�ap�Q���!	 �\�ح��|���]!yw�8���G,sV.f�&6�B�@GEg��7�:��������M��⿄I,r����t�����m�x�C��N�酯��������~X�}�W��7�o�������^>��ޒn6����������T� ���^�O�ئ�'#���Gڗ��?/�$p���M����|�����@����%<�<�<мP4���7J���G��u�����e�)rL�v�m�b�HT�-��1���-E�Z�Ho)T��C�	5#���dR�LY���N���?D����!��^�����y��f���u8���4u�W��9��w�i.���J~^�q��SI�zN��\SD�\�>#��Bd��d���i5ZV{x�-q#$-��V?~:)��I�R�t�T��bʬ&��xw�j�ű?����O���?���_z���Ɔ��8iw����������H���'�������Gڗ�� x���ʧ��?�����[�d$r���H�,�R����+��� ��]��������
�x ��D�O����.�Ij[�S����j��G�Jti_��2�g����?:|��G:��<��<�����p�)�?{�֝(�m����1Z=��&"�"���= �����&��;ڝT�teͧ��JJ��\s�5�Z�?���'�������2@����_-����� �/	5��� u��)�~����R�V�o^��p�m�S���9�:���õC*[8�p��YT���Br���������~^C��������'���<W�Of��������'�4q���\f��:ga=�n��n3�]j���I�iX�7�#��l��V�c����G�E�e-l�Ce�Зo����{���O�G�>o��2���|����]#n���	IMu�����r6O����}��ݢ�r{a�ɑ�GN���F�u�]#JI1�Ҥк�HT��*p(�;�,g?���S��{��r��ihˈ9��af57Ӡ�������iA,�j ��������W�z�?�D��Z���p8��@��?A��?U[�?�8�2P�����W�������?�7������?�&(�?u��a��:�9�o_��{�o�p��O����5�\�}�I�߸���~u����)�sw4<��ߗ��[��~���LC���I�W�h6Wz����v�V-��k�]�C�n��kFk�dW�(�Ă��Ͷ=�gdo"��,e3�C�����k]�:�?����N���|�=��A4s5����Gn}���������o8�k�%�oB)	7��R�0;� �����Z|���A�3�$a�^���rÆ�#�l�r�٥�d�����/��_Q��=��2P����>مP�W ���������O�_��/u����ǘ`Fa� ��)�R>�R(�q~�����L�A@ЄG3N�Jt@�!
g�8��������/�2�?+���8�B�o���dI�wwJ�<� �y{�����Wė��e���H�G_����ɚs�&�
2�w��r|��`���B��#EY$ǒ�t�h�&S?mFT����I��m��/�p�����P�����o������P�����P���\���_�/�:�?���W�Ô�&7��Q�Drp3�O9�Yvwr�Y��"��0K��O�tO�Q�3�q����#����V���%�e���0�����y��١a[�uN�Y��2�jd��]
�����ߊP�����~���߀:���Wu��/����/����_��h�*P��0w���A������[\�_D���G�^y/<��L�$ar,�&w���E%��?����6�����Ϝ�<=�g  ֳ� �H�@���P�"�C �<�7���8�lt�	��_�Kw7C��VS�:��mm�%��Fd�]F���PF��x�9����݂3���"r��\�E/O����|�� ��r]��;!�[�E|"���p�o7���q(H>��]'�5�,k�{�����2]��7Ls���V�X�_j\D���7ܟ4�l��<�PmwH[Mvz��ИL��Ǔ��v7HB϶�!�f�^���E�5C+��g����~��mr���#6�N��5G��Ѷ3�ދu��@���������&<�2��[�?�~��b(��(u�}�����RP
�C�_mQ��`����/������������j�0�����?��|��|�GIe���C2@=��<�&��AY�	ϟ^O����\H2!��^����:����Q����_9����òPS���箍#T���!/�$#'��vH����I�/��@��i$�ϖU�=٨���m����fM�4^�q���[��C�r%��ں��\w�9�mٻJ�[0��^���������|>�_#�~���C���?M`����Z�?}����_I(����:���:���j��\u�����?����\���?��N�����7�߯��@�>�mz���8O��rN�L��˕y7���K�w���qc������1�gf���l�g��|d�{oD�;Ղ��9��X�$���<Y�>L�G��m����4GF�#�7��hȬ�l�i���VS:�2n�K�a1j�O��%���¶��Γ
r��J�Y��kێ�w�s��A8d7�.sm�M�V�^��C���x�j��w��ʎx]vD��L3iD���oOB��
�q���m0�J��f��C�(N��Y�F'k�s�&�DN=Y�u�9X�x����E�c�S���.u����V�r���^W@����_������?��u�����������o����o�����<��_e`�P�m�W���u(�����.�E�� �� ��/�����������������������V�<�Q���H�OB�_
���8�����(�����m�j ��W��p�wU���!�b ��W��؃����������r�������^��e�,�����J�?@��?��G8~
��؝��%��6C*��_[�Ղ�������P#����
P���Q�	�� � �� �����*�Q!����������P/��p��Q���A�	�� � �� ����������RP�����W�������?�7���p�{)�����C������a�����%�O��{��0�e��o��}���� P�m�W�'^�����P'�ǰ��ѐ��0,��3�g�G�Dx!	��zh@�h�a,�q>�x�$��/��w��:�?AcP�W�?����:�T@���ɭ�Wڗ����
TP�ܻz����w����M.^�4���!ja��PF��qՒ h�?��!��`w3�1��,��'2�bH��U���!�K�l�3�Z��3l�J����I����C�����]�m��:�y���K��'U�^3�����ա���~]�JQ��?�ա��?�����{����U�_u����ï����S�ƾg��FK�}�;���?-��_���i�Sy��v��[keM�װ��n�N��A2g�9���S����Z��L��(�|��~���R�G�i3�QBS�v���eʀ�ｨ�����w�KB����G��_��0��_���`���`�����?��@-����������xK������o�O�$CB�;zc��lqd��,~s���~��{�vWi'	��*X�/�@�=D�uv�����4i�'��m�D����j;�K;bJ7�� #GZ0�����b�mgDf��)Y������$9r��F��+}��{�t�u��tZB����N��p���^G�\���nFQ?4��P�|+��N(�HeY������e���˦�����l9I��q��}"f���k����=�3�p�Jw�j|,����6\�KTl-W�Ɣ��$J�c��Ĳ9ۤ�5����
�$�'�i�{}x�;~���28�K�g\��|���'.��_�P�a��O��.���Jt��ڢ�����O��_���8���I��2P�?�zB�G�P��c����#Q�������(������8��t3����qBw:�����ү��hI�u������$W�7��n����s?t%������q������K�7߿�.=]�n���j]^��kj	��ؒ���B�8����u�!��Y�a:�@�FF�����)m5Z��NV�e*�?���5-5��a����9kb4)a��z�8�p���=c�-�c����[�쓕��y�[;wu���M��׼��o������!���ŧ��T��X��N�-����Ƚd�܌:�fۤ�?�Yz�޶_�̑��%A�c�wc����P�:`�t8�]���S�?�r�S!�X�H���izBn�&��[��.Ч�Y��ܔ���v�`�Y=iՓ_��Z�?�n���%��������̌�H��fD�y��I:�f(��8=�Ip3�`|:�4�9�� ��f�g������E���_)��������?���_�("���d�����vN>ݧ����B�2�/W��V��ȕ�Z�����?�W���
#��+u�C��?��JA	�p�j�2����}?�G��+o�����y��?u�{v}at6df0��������r�� o���9���]6�c���۸�3����C����u��y���w�����~&ﭶ)X��h��4���&��}rtԦ�3zkT�'�F�F�n����~d���O.�g�lT�׭N�igx�����~7�y��y�\�c�oF1�̔�8l0��S�-�F��4iY�|ī�e�k�cߏ���y�+>fϝ�z��v8f��w)Q"��f�^:y�h�����U�f�4Úsa��U�p���H]t�f��+��;��|���~7�A���`���p��<: ��fY%f,�_;~}��b�p����y�Ǣ��	.�`�b��uyc9̿OD����?�������+��V�^�
�-�k��6r��I��'r��P)�2o�h1h�/���˖�jA>*[��{/>�������(�e������
���������p�c-��_5�C�Wu(���c �T������A��������������I������ݮ�v{Yt����_����z��>��U��۹��ژ�B�o"�K�L���l,�!-��*�<�>?&}{,.��s�|�uu�\!OGW.���O������;�'5�m���_��I�:�<�<䡧Nn�"ؾ�޺��@@Q����v'��L:3i6ק*i�A�-|�Z{���>^���Jxa/�<���i9�Bg\�D{[[w:�T��hV�n�l=����}s|��*&��h�6�2�rڶ�t��H�1k	\�m����J	/Sh
�y���y�G�)q�<��n�x�=���gw;�b�ꇽ��v~��6lIi6F�í2�%Ym^���'�u����vcR��ld���j0��U���UL,ZJ�Ѷ�f�~���#ؕS�벵��R��p�qT��J%)�H]�+����|ß&�um�o��Ʉ,�C�?�����_��BG�����#��e�'_���L��O����O������ު���!�\��m�y���GG����rF.����o����&@�7���ߠ����-����_���-������gH���!��_�������_��C��@�A������_��T�����v ������E����(��B�����3W��@�� '�u!���_����� �����]ra��W�!�#P�����o��˅�/�?@�GF�A�!#���/�?$��2�?@��� �`�쿬�?����o��˅���?2r��P���/�?$���� ������h�������L@i�����������\�?s���eB>���Q�����������K.�?���D���V�1������߶���/R�?�������)�$�?g5���<7׭2m2��ͭb�5M�dR�����d˘d��ɱ÷�uz��E������lx��wz�(q��Fu����u��
M�)�ǭ�o2��wY��^�պ(����t�6ǝ6&w�Ɋ~HS,��8�m��/k��Ȏ�d�)-zB:]=h�V�E�Gu:,�q;,����m����d�U��\OS���՛�nǮU#�rEy�'����$YG���Wd�W�����E�n𜑇���U��a�7���y���AJ�?�}��n��%��:~��'jv��w�^���b�Q�ˆ��m��m��E��Ξ����Fu�j�[��j���#��͆�6,E�D8��~],���ߪb۰�sUk��ɫ�v��]mN���&�P;z��%�����7�{#��/D.� ����_���_0���������.��������_����n�QP�C��zVa��U���?��W��p���)VĚ8�)__�_ف����6��h�@*���z�.K�l�?���E��5}4o����D�0.L�x\��!iͱS��ˉI�U'�N��z�����~Q�j�J)l�[m,���m
��:;���_e�*��і����D�Z�F�1M!��bwXO����h�IJ�}v~s��V�~������^�|Jb���*P���r��KQ]٨5�V���v9X��ͦ2⇃8?LKQUZ�X�8���N�Y2D{�����qqېI�]?hB����|/Ƀ�G�P�	o��?� �9%���[�����Y������Y���?�xY������������Y������&��n�����SW�`�'����E�Q��-���\��+���	y���=Y����L�?��x{��#�����K.�?���/������ ���m���X���X�	������_
�?2���4�C����D�}{:bG[U�7��q������0�Z�)�#fs?��
����s?���L�G����"�w��Ϲ�������uy�ݢ��]�D�����8�P�;fm���\����j�7��O�gCvfNcap���M#��8:�!,Y��dSSmG��Q����Ѽ��_�Jޯ�WOG���\�F��4��
�}8V�����tu���_����Ug"��`1�lF90'<���%ik��Nt��jX#9jSo�}2�V,�X���`�fa�w��ReCi��DpT���vra���?2��/G�����m��B�a�y��Ǘ0
�)�������`�?������_P������"���G�7	���m��B�Y�9��+{� �[������-��RI��_�T�c�Q_D��q��Hmك�d�S����>�ǲ�<<�����،��i
���=��)������0��ыFI�h���z~��T�i��,u��7CS��W�*G}���hA�F�P/rq{+��eY!F�o� `i�����$�����B�{�X�/t)E�W��|aʜ�b�-?
�¢��nkO�����lX޴��P�G&��^S:K�X�!m�WЭ	�m�������?L.�?���/P�+���G��	���m��A��ԕ��E��,ȏ�3e�7�"oY�fh�f΋�N[,�s�N��E�d�l��a�OZk�:ϙ�O�9�c�V���L�������?r��?�������O�H&O��Q�Q�Nf��j�j�4*���<�ބ&{�`��Vb�埈`g��kL^�J���������ʝJ]X��5rr�4׉Y<�ZV p�|��n4��?_K���������q�������\�?�� ��?-������&Ƀ����������z�X�􎬊Ĝ�*Ċ��K���[Q�Ew��/�N��>�\_:���`K��_a;�YRL=4�,�G�~u�N�����[�iW||Ռڲn0.O������&^����24��%��E��3��g����``��"���_���_���?`���y��X��"�e��S�ϖ>�����ct�\���t/B�����S�����X �������wں�E[M�$������q��tc����r�J̧2�"��rV�#��'�`�)��Byh�X��a���שҬ�ڶ��RW�/�<,��DM���';O|�V�OE�;�q:&�BwX��u� v-a��$:9�6�RIv��������my�(�+�*"c���=QJ��S�M��MԵ�_�S��i�򳽈}U8P��Hԫ+��u��ˆď䓻p��J��ڞ[���b�n�0Fb��*4��Â�S�}�1�Յި���|8ezTqZ&�r�w��#O�9��}tx]���'����B�i&��?�ݹm�x������:��_v��Gm�(�����	bO�>J5�cG�?��+�y����<�Y���t�Ϧ��|L������]$�=c��������{=���G�����CI�������5�L�X���R��7?�%�����?}J����p�}���?�㾊��i>�����������.0�ox��D����n���Ǎpm�N������{,4#���'縉�i$����I_�zR��v��I�d���r��x�0qcfr��${{��(����7�x�#����w��~�c�=�I��%���w�����w܏�ɫ���[~I��OO;v������<Q�T ���;�r��}u��������<��XK����~��`m�m3�Ϗy��ӕ�渆�޳�M��"�`纎k��DނO��?q'w&�� �Bo�q�4����ÿ�Z�~����f�?�i,<��/���צ�������{��$�|��9��f@�{�M�t����?n�q��W��œ,���67aF���x�s�pM�ӓU=���SJZ��E�qwɍ'�{Տ�j�����H�VM�;���Hva*�����t�w�j�ez�w�ח������=q�}                           p��CsD � 