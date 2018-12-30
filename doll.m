% membaca gambar
A = imread('doll.jpg');
% memotong gambar
CropA = A(1:320, 1:480, :);
[baris, kolom, layer] = size(CropA);
% mengubah gambar menjadi abu-abu
B = rgb2gray(CropA);

j = 0;
for c = 1 : 40 : 281
    for d = 1 : 40 : 441
        e = c + 39;
        f = d + 39;
        if(j==0)
            dataPotongan = [c e d f];
        else
            dataPotongan = [dataPotongan; c e d f];
        end;
        j=j+1;
    end;
end;


for i=1:j;
   data = CropA( dataPotongan(i,1):dataPotongan(i,2), dataPotongan(i,3):dataPotongan(i,4) );
   gcm = graycomatrix(data,'Offset',[-1 1]);
   
   if(i==1)
      stat = [graycoprops(gcm)];
   else
      stat = [stat; graycoprops(gcm)];
   end

   % mengambil nilai korelasi
   corr = stat(i).Correlation;
   % mengambil nilai homogeniti
   homo = stat(i).Homogeneity;
   % mengambil nilai entropy
   entr = entropy(data);
   % mengambil nilai rata-rata
   maen = mean(mean(data));
   
   if(i==1)
       feature = [corr homo entr maen];
	   % menginisialisai nilai min dan max
       minCorr = corr;
       maxCorr = corr;
       minHomo = homo;
       maxHomo = homo;
       minEntr = entr;
       maxEntr = entr;
       minMean = maen;
       maxMean = maen;
   else
       feature = [feature; corr homo entr maen];
   end
   
   % mencari nilai min dan max
   if(corr<minCorr) minCorr = corr; end
   if(corr>maxCorr) maxCorr = corr; end
   if(homo<minHomo) minHomo = homo; end
   if(homo>maxHomo) maxHomo = homo; end
   if(maen<minMean) minMean = maen; end
   if(maen>maxMean) maxMean = maen; end
   if(entr<minEntr) minEntr = entr; end
   if(entr>maxEntr) maxEntr = entr; end

end

% melakukan proses normalisasi
for i=1:j
   feature(i,1) = (feature(i,1)-minCorr) / (maxCorr-minCorr);
   feature(i,2) = (feature(i,2)-minHomo) / (maxHomo-minHomo);
   feature(i,3) = (feature(i,3)-minEntr) / (maxEntr-minEntr);
   feature(i,4) = (feature(i,4)-minMean) / (maxMean-minMean);
end

% memanggil dan menjalankan proses klustering menggunakan K Means dengan 2 label/class
hasil = kmeans(feature,2);
hasilKmeans = size(CropA);
for i=1:j
    if(hasil(i) == 1)
        hasilKmeans( dataPotongan(i,1):dataPotongan(i,2), dataPotongan(i,3):dataPotongan(i,4)) = 1;
    else
        hasilKmeans( dataPotongan(i,1):dataPotongan(i,2), dataPotongan(i,3):dataPotongan(i,4)) = 0;
    end
end

% seleksi gambar yang bernilai 1 dan mengembalikannya ke gambar berwarna
boneka = zeros(320, 480, 3);
for i=1:320
    for k=1:480
        if(hasilKmeans(i,k) == 1)
            boneka(i,k,:) = CropA(i,k,:);
        end;
    end;
end;
boneka = uint8(boneka);

% melakukan seleksi berdasarkan warna RGB
imgBaru = zeros(baris, kolom, 3);
for i=1:baris
    for j=1:kolom
        if (boneka(i,j,1) >= 82 && boneka(i,j,1)<=240) && (boneka(i,j,2) >= 62 && boneka(i,j,2) <= 207) && (boneka(i,j,3) >= 19 && boneka(i,j,3) <= 168)
            imgBaru(i,j,:) = 0;
        else
            imgBaru(i,j,:) = boneka(i,j,:);
        end;
    end;
end;

% mengubah gambar menjadi abu-abu
imgBaruGray = rgb2gray(imgBaru);

% mengubah gambar abu-abu menjadi gambar logic
imgBaruLogic = zeros(baris, kolom);
for i=1:baris
    for j=1:kolom
        if imgBaruGray(i,j) ~= 0
            imgBaruLogic(i,j) = 1;
        end;
    end;
end;

% menambal gambar yang berlubang
imgBaruTambal = imfill(imgBaruLogic,'holes');
imgBaru = uint8(imgBaru);

% membuat label dari objek yang ada
[M, jml] = bwlabel(imgBaruTambal);

img = zeros(baris, kolom, layer);

%seleksi dengan luas objek tertentu
idxDoll = [];
for i=1:jml
   luasObjek(i) = numel(find(M == i));
   if (numel(find(M == i)) > 25000)
       idxDoll = [idxDoll i];
   end;
end;

% ambil gambar yang telah dilakukan berbagai macam proses segmentasi
for i=1:baris
    for j=1:kolom
        if ismember(M(i,j),idxDoll)
            img(i,j,:) = boneka(i,j,:);
            
        end;
    end;
end;

img = uint8(img);

subplot(1,2,1), imshow(img),subplot(1,2,2), imshow(boneka);

%imshow(contohj);

%imhist(contohj(:,:,1);
%subplot(2,2,1),imhist(contohj(:,:,1)),subplot(2,2,2),imhist(contohj(:,:,2)),subplot(2,2,3),imhist(contohj(:,:,3)),subplot(2,2,4),imshow(contohj);
%subplot(2,2,1),imshow(contohj),subplot(2,2,2),imshow(contoh),subplot(2,2,3),imshow(CropA);

