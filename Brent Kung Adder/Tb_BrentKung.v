
module Tb_BrentKung;
reg[31:0] a;
reg[31:0] b;
wire[31:0] s;
wire cout;
reg cin;
reg [32:0] ans;
reg [31:0] inputVec[102:0];
integer i, j, f;
 
 Brent_Kung ap (a,b,cin,s,cout);
 initial
 begin
 f = $fopen("output.txt","w");
     $readmemh("input.txt", inputVec);

    cin = 1'b0;
    for (i = 0; i < 103; i = i + 1) begin
      for (j = 0; j <103; j = j + 1) begin
        a = inputVec[i];
        b = inputVec[j];
        ans = a + b + cin;

        #20
        $fwrite(f, "a = %h, b = %h, Cin = %b, Cout = %b, S = %h", a, b, cin, cout, s);
        if ({cout,s} !== ans) 
		       $fwrite(f, "ERROR: incorrect sum", ans);
        $fwrite(f, "\n");
      end
    end

    $fclose(f);
  end

endmodule