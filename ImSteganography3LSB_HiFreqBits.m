%%---------------------------------------
%       Digital Image Processing
%       ------------------------
%         Image Steganography
%        ----------------------
%        Ran Malach ® 62887906
%%---------------------------------------

%% Embed Image
close all; clear all;
name={'carriage.jpg','TlvAzrieli.jpg','TLV.jpg'};
for l=1:3 % Loop for every cover Image
tic % Take time interval for embedding process
cover=imread(name{l});f=cover; %cover - Image to be shown
trojan=imread('e2.png'); % trojan - Image to be hidden
sz=size(trojan);
I=cover(:,:,1)-mod(cover(:,:,1),8); % Hiding 3 bits in LSB - mod 8
m=edge(I);g=m; % find pixels of low energy
[y x]=find(m);
k=(length(x)-3)/(ceil(sz(1)*sz(2)*8/3)); %check whether its possible to hide the image
if (k<1)
    display('not enough space in the cover Image to hide the trojan Image');
    return;
else 
    display(['trojan Image takes ',num2str(1/k*100),'%',' of available cover Image hiding capacity']);
end
C=cell(1,3); % Each cell is for lexicographical order of RGB hidden image bits
for d=1:3
    C{d}=[];
    p=trojan(:,:,d);
    p=p(:);
    for n=1:length(p)
        C{d}=[C{d} dec2bin(p(n),8)];
    end
end
N=mod(length(p)*8,3);
for d=1:3
for n=1:3-N
    C{d}=[C{d} '0']; %Fix the length of the lexicographic image so its divided by 3
end
end
for d=1:3
    for n=1:length(C{1})/3 % Add the secret 3 bit value to the cover Image Low Energy bits
        cover(y(n),x(n),d)=cover(y(n),x(n),d)-mod(cover(y(n),x(n),d),8)+bin2dec(C{d}((n-1)*3+1:n*3));
    end
end
for d=1:3
m=dec2bin(sz(d),9); % Arrange the size of the Image to be hidden
for n=1:3 % hide the size of the Image in the last 3 pixels of each (Low Energy coordinates)color layer
    cover(y(end-3+n),x(end-3+n),d)=...
        cover(y(end-3+n),x(end-3+n),d)-mod(cover(y(end-3+n),x(end-3+n),d),8)+bin2dec(m((n-1)*3+1:n*3));
end
end
imwrite(cover,[name{l}(1:end-4) '_' 'embedded' '.png']); % write the Embedded Image
h=toc; % Take time
figure;
subplot 223;imshow(g);title({'Pixels of low energy','Trojan Image will be hidden here in 3 LSBs'});axis off;
subplot 222;imshow(trojan);title({'Trojan Image',...
    ['Takes ',num2str(1/k*100),'%',' of available cover Image hiding capacity'],...
    ['tictoc=',num2str(h),' sec']});
subplot 221;imshow(f);title('Original Cover Image');
subplot 224;imshow(cover);title({'Embedded Image',...
    ['\surdIMMSE(embed,orig)=',num2str(sqrt(immse(f,cover)))],...
    ['PSNR=',num2str(psnr(f,cover)),'dB'],...
    ['SSIM=',num2str(ssim(cover,f))]});axis off;
end
%% Extract Image
close all; clear all;
%%
name={'carriage','TlvAzrieli','TLV'};
for l=1:3 % Loop for each one of the embedded Images
cover=imread([name{l} '_embedded.png']);tic % Read embedded Image & take time
J=cover(:,:,1) - mod(cover(:,:,1),8); % Subtract to mod 8 value in order to erase 3 LSB's
mask=edge(J); % Find the coordinates of the secret Image bits
[yy xx]=find(mask);
sz=zeros(1,3);si=[];
for d=1:3
    for n=1:3   % Extract the size of the secret Image
        si=[si dec2bin(mod(cover(yy(end-3+n),xx(end-3+n),d),8),3)];
    end
end
sz(1)=bin2dec(si(1:9));sz(2)=bin2dec(si(10:18));sz(3)=bin2dec(si(19:27));

n=sz(1)*sz(1);N=mod(n*8,3);
N=n*8+3-N;
D=cell(1,3);
for d=1:3
    D{d}=[]; % Extract and Concatenate all secret bits
    for n=1:N/3
        f=mod(cover(yy(n),xx(n),d),8);
        D{d}=[D{d} dec2bin(f,3)];
    end
end
E=cell(1,3);
for d=1:3
    E{d}=[]; % Transform Extracted Bits into lexicographical order image RGB layes
    for n=1:sz(1)*sz(2)
        E{d}=[E{d} bin2dec(D{d}((n-1)*8+1:8*n))];
    end
end
p=zeros(sz);
for d=1:3 % Reshape lexicographical order Into image p
    p(:,:,d)=reshape(E{d},[sz(1) sz(2)]);
end
p=uint8(p);
h=toc;
figure;
subplot 311;imshow(cover);title('Embedded Image');
subplot 312; imshow(mask);title({'Pixels of low energy','Trojan Image is hidden here in 3 LSBs'});axis off;
subplot 313; imshow(p); title({'Extracted Image',...
                        ['IMMSE(orig,extracted)=',num2str(immse(p,imread('e2.png')))],...
                        ['tictoc= ',num2str(h)]});
end
