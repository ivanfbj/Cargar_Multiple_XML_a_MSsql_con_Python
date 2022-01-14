import os
import pyodbc
from tqdm import tqdm

class bcolors:
    OK = '\033[92m' #GREEN
    WARNING = '\033[93m' #YELLOW
    FAIL = '\033[91m' #RED
    HIGHLIGHTER = '\033[97m\033[102m' # letter white -  background GREEN
    RESET = '\033[0m' #RESET COLOR
    # 0m -> reiniciar
    # 90m - 97m -> colores
    # 100m - 107m -> colores de fondo


full_path_file_list = []
table_name = 'data_xml'
# table_name = 'data_xml_nube'
with open(f'listado_completo_XML_{table_name}.txt', 'w') as temp_file:
    for root, dirs, files in tqdm(os.walk(os.path.abspath(r".\archivos_XML")), desc=f'{bcolors.OK} Carpetas Recorridas    '):
        for file in files:
            # print(full_path_files)
            full_path_file = os.path.join(root, file)
            if full_path_file.endswith('.XML') or full_path_file.endswith('.xml'):
                temp_file.write(full_path_file)
                temp_file.write("\n")
                full_path_file_list.append(full_path_file)
print(f"{bcolors.OK} Cantidad de XML encontrados: {len(full_path_file_list)} {bcolors.RESET}")


# Se declaran las variables que permitirán la conexión con la base de datos
driver_name = 'SQL Server'
server_name = 'AGN5\SQLEXPRESS'  # select @@SERVERNAME
database_name = 'test_xml_python'
user_name = 'pythonSql_xml'
password = '123456789'

# Se estable la conexión a la base de datos con sus respectivo valores anteriormente declarados
connection = pyodbc.connect(f'DRIVER={driver_name};SERVER={server_name};DATABASE={database_name};UID={user_name};PWD={password}')

cursor = connection.cursor()

cursor.execute(f'TRUNCATE TABLE {table_name}')

if os.path.exists("./listado_XML_con_error.txt"):
    os.remove("./listado_XML_con_error.txt")


for path_file in tqdm(full_path_file_list, desc='Recorriendo Lista de rutas para insertar en base de datos: '):
    # print(f"{bcolors.WARNING} RECORRIENDO LISTA DE RUTAS {bcolors.RESET}")
    container_folder_name, file_name = os.path.split(path_file)  # Separando la ruta del nombre del archivo
    # print(path_file)  # ruta completa
    # print(file_name)  # nombre del archivo
    # print(container_folder_name.split('\\')[-1])  # Carpeta contenedora del archivo
    only_container_folder_name = container_folder_name.split('\\')[-1]
    try:
        cursor.execute(f"""INSERT INTO {table_name}(XmlCol , local_path, container_folder_name, name_file )  
                            SELECT *, '{path_file}', '{only_container_folder_name}', '{file_name}'
                                FROM OPENROWSET(  
                                        BULK '{path_file}',  
                                        SINGLE_BLOB
                                        ) AS op_xml
                        """)
    except:
        with open(f'listado_XML_con_error_{table_name}.txt', 'a') as temp_file_error:
            temp_file_error.write(path_file)
            temp_file_error.write("\n")
        # print(f'{bcolors.FAIL} ERROR {path_file} {bcolors.RESET}')
    # print("'",path_file.strip(),"'")
    connection.commit()


# Cerrar la conexión a la base de datos
cursor.close()
connection.close()