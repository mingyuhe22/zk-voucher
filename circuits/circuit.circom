pragma circom 2.1.5;

include "../node_modules/circomlib/circuits/eddsaposeidon.circom";

function LenOfSig(){
    return 3;
}
template Sig(){
    signal input arr[LenOfSig()];
    signal output (RX, RY, S) <== (arr[0], arr[1], arr[2]);
}
template Sig_Verify(){
    signal input sig[LenOfSig()], enabled, digest, pubKeyX, pubKeyY;
    signal (RX, RY, S) <== Sig()(sig);
    EdDSAPoseidonVerifier()(enabled, pubKeyX, pubKeyY, S, RX, RY, digest);
}
function LenOfVoucher(){
    return 5;
}
template Voucher(){
    signal input arr[LenOfVoucher()];
    signal output amount <== arr[0];
    signal output receiver_addr <== arr[1];
    signal output sig[LenOfSig()];
    (sig[0], sig[1], sig[2]) <== (arr[2], arr[3], arr[4]);
}
template Voucher_VerifySig(){
    signal input voucher[LenOfVoucher()], enabled, pubKeyX, pubKeyY;
    component voucher_ = Voucher();
    voucher_.arr <== voucher;
    Sig_Verify()(voucher_.sig, enabled, voucher_.amount, pubKeyX, pubKeyY);
}
template ZkVoucher(batch_size){
    signal input pubKeyX_, pubKeyY_, voucher[batch_size][LenOfVoucher()];
    var sum = 0;
    for(var i = 0; i < batch_size; i++){
        Voucher_VerifySig()(voucher[i], 1, pubKeyX_, pubKeyY_);
        sum += voucher[i][0];
    }
    for(var i = 1; i < batch_size; i++){
        voucher[0][1] === voucher[i][1];
    }
    signal output amount <== sum;
    signal output pubKeyX <== pubKeyX_;
    signal output pubKeyY <== pubKeyY_;
    signal output receiver_addr <== voucher[0][1];
}
component main = ZkVoucher(10);