-- migrate:up
CREATE INDEX idx_products_parent_id ON products(parent_product_id);

-- migrate:down
DROP INDEX IF EXISTS idx_products_parent_id;
