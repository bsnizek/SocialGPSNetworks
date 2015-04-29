from geoalchemy2 import Geometry
from geoalchemy2.shape import to_shape
from sqlalchemy import create_engine, Column, String, DateTime, Integer
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker

__author__ = 'besn'

Base = declarative_base()

class PalmsOutputGeom(Base):
    __tablename__ = 'palms_output_geom'
    uid = Column(Integer, primary_key=True)
    unique_trip_id = Column(String)
    geom = Column(Geometry('POINT'))
    palms_datetime = Column(DateTime)
    identifier = Column(String)

    def __repr__(self):
        return "<%s : %s>" % (self.unique_trip_id, self.palms_datetime)

    @property
    def point(self):
        """
        Returns the coordinate of the point object
        :return:
        """
        return to_shape(self.geom)

class UserUserDistance


engine = create_engine('postgresql://odense:odense@127.0.0.1:5432/odense')


session = sessionmaker()
session.configure(bind=engine)
Base.metadata.create_all(engine)

s = session()

for (v) in s.query(PalmsOutputGeom.palms_datetime).distinct():
    pog = s.query(PalmsOutputGeom).filter(PalmsOutputGeom.palms_datetime == v).all()
    for p1 in pog:
        for p2 in pog:
            distance = p1.point.distance(p2.point)
            print(p1.uid, p2.uid, distance)

