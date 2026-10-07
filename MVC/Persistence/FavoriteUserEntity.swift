import CoreData

@objc(FavoriteUserEntity)
final class FavoriteUserEntity: NSManagedObject {
    @NSManaged var id: Int64
    @NSManaged var name: String?
    @NSManaged var username: String?
    @NSManaged var email: String?
    @NSManaged var phone: String?
    @NSManaged var website: String?
    @NSManaged var street: String?
    @NSManaged var suite: String?
    @NSManaged var city: String?
    @NSManaged var zipcode: String?
    @NSManaged var lat: String?
    @NSManaged var lng: String?
    @NSManaged var companyName: String?
    @NSManaged var companyCatchPhrase: String?
    @NSManaged var companyBs: String?
    @NSManaged var avatarData: Data?
    @NSManaged var weatherData: Data?
    @NSManaged var weatherUpdatedAt: Date?
    @NSManaged var addedAt: Date?

    @nonobjc class func fetchRequest() -> NSFetchRequest<FavoriteUserEntity> {
        NSFetchRequest<FavoriteUserEntity>(entityName: "FavoriteUserEntity")
    }

    func apply(_ user: User) {
        id = Int64(user.id)
        name = user.name
        username = user.username
        email = user.email
        phone = user.phone
        website = user.website
        street = user.address.street
        suite = user.address.suite
        city = user.address.city
        zipcode = user.address.zipcode
        lat = user.address.geo.lat
        lng = user.address.geo.lng
        companyName = user.company.name
        companyCatchPhrase = user.company.catchPhrase
        companyBs = user.company.bs
    }

    var user: User {
        User(
            id: Int(id),
            name: name ?? "",
            username: username ?? "",
            email: email ?? "",
            address: Address(
                street: street ?? "",
                suite: suite ?? "",
                city: city ?? "",
                zipcode: zipcode ?? "",
                geo: Geo(lat: lat ?? "0", lng: lng ?? "0")
            ),
            phone: phone ?? "",
            website: website ?? "",
            company: Company(
                name: companyName ?? "",
                catchPhrase: companyCatchPhrase ?? "",
                bs: companyBs ?? ""
            )
        )
    }
}
