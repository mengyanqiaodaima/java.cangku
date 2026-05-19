-- 创建数据库
CREATE DATABASE IF NOT EXISTS warehouse_management;
USE warehouse_management;

-- 仓库表（增加状态、描述字段）
CREATE TABLE IF NOT EXISTS warehouse (
    id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '主键ID',
    code VARCHAR(20) NOT NULL UNIQUE COMMENT '仓库编码',
    name VARCHAR(50) NOT NULL COMMENT '仓库名称',
    address VARCHAR(100) COMMENT '仓库地址',
    manager VARCHAR(20) COMMENT '仓库管理员',
    phone VARCHAR(15) COMMENT '联系电话',
    status TINYINT DEFAULT 1 COMMENT '状态：1启用 0禁用',
    description VARCHAR(200) COMMENT '仓库描述',
    create_time DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    update_time DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='仓库表';

-- 物资分类表（增加排序、描述字段）
CREATE TABLE IF NOT EXISTS material_category (
    id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '主键ID',
    code VARCHAR(20) NOT NULL UNIQUE COMMENT '分类编码',
    name VARCHAR(50) NOT NULL COMMENT '分类名称',
    parent_id BIGINT DEFAULT 0 COMMENT '父分类ID，0表示顶级分类',
    sort INT DEFAULT 0 COMMENT '排序号',
    description VARCHAR(200) COMMENT '分类描述',
    create_time DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    update_time DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='物资分类表';

-- 物资台账表（增加单位、参考单价、最低库存量）
CREATE TABLE IF NOT EXISTS material_ledger (
    id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '主键ID',
    code VARCHAR(30) NOT NULL UNIQUE COMMENT '物资编码',
    name VARCHAR(100) NOT NULL COMMENT '物资名称',
    specification VARCHAR(50) NOT NULL COMMENT '规格',
    material VARCHAR(50) NOT NULL COMMENT '材质',
    unit VARCHAR(10) NOT NULL COMMENT '单位',
    price DECIMAL(10,2) DEFAULT 0.00 COMMENT '参考单价',
    min_stock INT DEFAULT 0 COMMENT '最低库存量',
    supplier VARCHAR(100) COMMENT '供应商',
    brand VARCHAR(50) COMMENT '品牌',
    category_id BIGINT NOT NULL COMMENT '分类ID',
    create_time DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    update_time DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    UNIQUE KEY uk_code (code),
    INDEX idx_name (name),
    FOREIGN KEY (category_id) REFERENCES material_category(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='物资台账表';

-- 入库单表（保持原样）
CREATE TABLE IF NOT EXISTS warehouse_in (
    id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '主键ID',
    code VARCHAR(30) NOT NULL UNIQUE COMMENT '入库单编码',
    warehouse_id BIGINT NOT NULL COMMENT '仓库ID',
    operator VARCHAR(20) NOT NULL COMMENT '操作员',
    remark VARCHAR(200) COMMENT '备注',
    create_time DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    FOREIGN KEY (warehouse_id) REFERENCES warehouse(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='入库单表';

-- 入库单明细表（数量改为DECIMAL，增加批次号非空约束）
CREATE TABLE IF NOT EXISTS warehouse_in_detail (
    id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '主键ID',
    in_id BIGINT NOT NULL COMMENT '入库单ID',
    material_id BIGINT NOT NULL COMMENT '物资ID',
    quantity DECIMAL(12,2) NOT NULL COMMENT '入库数量',
    unit_price DECIMAL(15,2) NOT NULL COMMENT '单价',
    amount DECIMAL(15,2) NOT NULL COMMENT '金额',
    batch_no VARCHAR(30) NOT NULL COMMENT '批次号',
    FOREIGN KEY (in_id) REFERENCES warehouse_in(id) ON DELETE CASCADE,
    FOREIGN KEY (material_id) REFERENCES material_ledger(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='入库单明细表';

-- 出库单表（同入库单表结构）
CREATE TABLE IF NOT EXISTS warehouse_out (
    id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '主键ID',
    code VARCHAR(30) NOT NULL UNIQUE COMMENT '出库单编码',
    warehouse_id BIGINT NOT NULL COMMENT '仓库ID',
    operator VARCHAR(20) NOT NULL COMMENT '操作员',
    remark VARCHAR(200) COMMENT '备注',
    create_time DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    FOREIGN KEY (warehouse_id) REFERENCES warehouse(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='出库单表';

-- 出库单明细表
CREATE TABLE IF NOT EXISTS warehouse_out_detail (
    id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '主键ID',
    out_id BIGINT NOT NULL COMMENT '出库单ID',
    material_id BIGINT NOT NULL COMMENT '物资ID',
    quantity DECIMAL(12,2) NOT NULL COMMENT '出库数量',
    unit_price DECIMAL(15,2) NOT NULL COMMENT '单价',
    amount DECIMAL(15,2) NOT NULL COMMENT '金额',
    batch_no VARCHAR(30) NOT NULL COMMENT '批次号',
    FOREIGN KEY (out_id) REFERENCES warehouse_out(id) ON DELETE CASCADE,
    FOREIGN KEY (material_id) REFERENCES material_ledger(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='出库单明细表';

-- 库存表（批次号不允许NULL）
CREATE TABLE IF NOT EXISTS inventory (
    id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '主键ID',
    material_id BIGINT NOT NULL COMMENT '物资ID',
    warehouse_id BIGINT NOT NULL COMMENT '仓库ID',
    quantity DECIMAL(12,2) NOT NULL COMMENT '库存数量',
    batch_no VARCHAR(30) NOT NULL COMMENT '批次号',
    update_time DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    UNIQUE KEY uk_material_warehouse_batch (material_id, warehouse_id, batch_no),
    FOREIGN KEY (material_id) REFERENCES material_ledger(id),
    FOREIGN KEY (warehouse_id) REFERENCES warehouse(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='库存表';