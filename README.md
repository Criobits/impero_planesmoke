# impero_planesmoke

## Query da lanciare per creare la tabella a DB
CREATE TABLE IF NOT EXISTS `smokester_planes` (
  `plate`       VARCHAR(8)   NOT NULL,
  `owner`       VARCHAR(32)  NOT NULL,
  `smoke_color` INT          NOT NULL,
  `smoke_size`  FLOAT        NOT NULL DEFAULT 1.0,
  PRIMARY KEY (`plate`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

## Items da aggiungere/creare
['smoke_red']    = { name='smoke_red',    label='Carica Fumo Rosso',    weight=100, stack=false, close=true, description='Sblocca fumo rosso per questo aereo.' },
['smoke_orange'] = { name='smoke_orange', label='Carica Fumo Arancione', weight=100, stack=false, close=true, description='Sblocca fumo arancione per questo aereo.' },
['smoke_yellow'] = { name='smoke_yellow', label='Carica Fumo Giallo',    weight=100, stack=false, close=true, description='Sblocca fumo giallo per questo aereo.' },
['smoke_green']  = { name='smoke_green',  label='Carica Fumo Verde',     weight=100, stack=false, close=true, description='Sblocca fumo verde per questo aereo.' },
['smoke_blue']   = { name='smoke_blue',   label='Carica Fumo Blu',       weight=100, stack=false, close=true, description='Sblocca fumo blu per questo aereo.' },
['smoke_purple'] = { name='smoke_purple', label='Carica Fumo Viola',     weight=100, stack=false, close=true, description='Sblocca fumo viola per questo aereo.' },
['smoke_white']  = { name='smoke_white',  label='Carica Fumo Bianco',    weight=100, stack=false, close=true, description='Sblocca fumo bianco per questo aereo.' },
['smoke_black']  = { name='smoke_black',  label='Carica Fumo Nero',      weight=100, stack=false, close=true, description='Sblocca fumo nero per questo aereo.' },