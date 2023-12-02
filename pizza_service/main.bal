    import ballerina/http;
    import ballerina/sql;
    // import ballerina/os;
    import ballerinax/postgresql;
    import ballerinax/postgresql.driver as _;

    type Dish record {|
        int id;
        string name;
        decimal price;
        string description;
        string image_url;
        json tags;
    |};

    // string envServerPort = os:getEnv("SERVER_CONTAINER_PORT");
    // int serverPort = check int:fromString(envServerPort);

    // string envPgPort = os:getEnv("SERVER_CONTAINER_PORT");
    // int pgPort = check int:fromString(envPgPort);

    int serverPort = 8099;
    int pgPort = 5433;

    postgresql:Options postgresqlOptions = {
        connectTimeout: 10,
        ssl: {
            mode: postgresql:DISABLE
        }
    };

    service / on new http:Listener(serverPort) {
        private final postgresql:Client db;

        function init() returns error? {
            self.db = check new (
                "postgres",
                "bal_user",
                "vnjeuhg82wg9g",
                "bal_db",
                pgPort,
                options = postgresqlOptions);
        }

        resource function get getAllDishes() returns Dish[]|error {
            stream<Dish, sql:Error?> dishStream = self.db->query(`SELECT * FROM dish`);
            return from Dish dish in dishStream
                select dish;
        }
    }
