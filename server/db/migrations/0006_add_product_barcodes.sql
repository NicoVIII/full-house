-- migrate:up
create table product_barcodes (
  product_id text not null references products(id) on delete cascade,
  barcode text not null,
  primary key (product_id, barcode)
);

create unique index idx_product_barcodes_barcode
  on product_barcodes(barcode);

-- migrate:down
drop index if exists idx_product_barcodes_barcode;
drop table if exists product_barcodes;
