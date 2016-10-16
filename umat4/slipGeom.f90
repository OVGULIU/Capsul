module typeSlipGeom
  use utils, only : RKIND, IKIND
  implicit none

  integer(kind = IKIND), public, parameter :: kFCC  = 1
  integer(kind = IKIND), public, parameter :: kBCC  = 2
  integer(kind = IKIND), public, parameter :: kHCP  = 3
  integer(kind = IKIND), public, parameter :: kUSER = 4

  !********* Declaration of base class SlipGeom
  type, abstract, public :: SlipGeom
    integer(kind = IKIND)              :: fNumSlipSys
    integer(kind = IKIND)              :: fNumSlipSet
    integer(kind = IKIND), allocatable :: fSlipSet(:)
    real(kind = RKIND),    allocatable :: fSlipVecS(:, :)
    real(kind = RKIND),    allocatable :: fSlipVecM(:, :)
    real(kind = RKIND),    allocatable :: fSchmidt(:, :, :)

  contains
    procedure, public :: NumSlipSys
    procedure, public :: NumSlipSet
    procedure, public :: SlipSet
    procedure, public :: Schmidt

    procedure, public :: InitSlipGeom
    procedure, public :: DestroySlipGeom

    procedure, private :: SetSchmidt
    procedure(SetSlipVectorsIntf), private, deferred :: SetSlipVectors
  end type SlipGeom

  abstract interface
    subroutine SetSlipVectorsIntf(this)
      import SlipGeom
      class(SlipGeom) :: this
    end subroutine SetSlipVectorsIntf
  end interface
  !**********End of declaration of class SlipGeom

contains

  subroutine InitSlipGeom(this)
    class(SlipGeom), intent(inout) :: this

    allocate(this%fSlipSet(this%fNumSlipSys))

    allocate(this%fSlipVecS(3, this%fNumSlipSys))
    allocate(this%fSlipVecM(3, this%fNumSlipSys))
    allocate(this%fSchmidt(3, 3, this%fNumSlipSys))

    call this%SetSlipVectors()
    call this%SetSchmidt()

  end subroutine InitSlipGeom


  subroutine DestroySlipGeom(this)
    class(SlipGeom) :: this

    if (allocated(this%fSlipSet))  deallocate(this%fSlipSet)
    if (allocated(this%fSlipVecS)) deallocate(this%fSlipVecS)
    if (allocated(this%fSlipVecM)) deallocate(this%fSlipVecM)
    if (allocated(this%fSchmidt))  deallocate(this%fSchmidt)

  end subroutine DestroySlipGeom


  function NumSlipSys(this) result(nSlipSys) 
    integer(kind = IKIND) :: nSlipSys
    class(SlipGeom), intent(in) :: this

    nSlipSys = this%fNumSlipSys
  
  end function NumSlipSys


  function NumSlipSet(this) result(nSlipSet) 
    integer(kind = IKIND) :: nSlipSet
    class(SlipGeom), intent(in) :: this

    nSlipSet = this%fNumSlipSet
  
  end function NumSlipSet


  function SlipSet(this) result(theSlipSet) 
    class(SlipGeom), intent(in) :: this
    integer(kind = IKIND) :: theSlipSet(this%fNumSlipSys)

    theSlipSet = this%fSlipSet
  
  end function SlipSet

  subroutine SetSchmidt(this)
    use algebra, only : normalize, out_product
    class(SlipGeom) :: this
    integer :: i

    do i = 1, this%fNumSlipSys
      call normalize(this%fSlipVecS(:, i))
      call normalize(this%fSlipVecM(:, i))
      this%fSchmidt(:, :, i) = out_product(this%fSlipVecS(:, i), this%fSlipVecM(:, i))
    end do

  end subroutine SetSchmidt


  function Schmidt(this) result(theSchmidt)
    class(SlipGeom), intent(in) :: this
    real(kind = RKIND) :: theSchmidt(3, 3, this%fNumSlipSys)

    theSchmidt = this%fSchmidt

  end function Schmidt


end module typeSlipGeom



module typeSlipGeomFCC
  use utils, only : RKIND, IKIND
  use typeSlipGeom
  implicit none


  !**********Declaration of derived class FCCGeom
  type, extends(SlipGeom), public :: SlipGeomFCC
  contains
    procedure, private :: SetSlipVectors
    final     :: Destructor
  end type SlipGeomFCC

  interface SlipGeomFCC
    module procedure Constructor
  end interface
  !********** End of declaration of class FCCGeom

contains

  function Constructor() result(this)
    type(SlipGeomFCC), pointer :: this

    integer(kind = IKIND), parameter :: kNumSlipSet = 1
    integer(kind = IKIND), parameter :: kNumSlipSys = 12

    allocate(this)

    this%fNumSlipSet = kNumSlipSet
    this%fNumSlipSys = kNumSlipSys

    call this%InitSlipGeom()

  end function Constructor


  subroutine Destructor(this)
    type(SlipGeomFCC) :: this

    call this%DestroySlipGeom()

  end subroutine Destructor


  subroutine SetSlipVectors(this)
    class(SlipGeomFCC) :: this

    this%fSlipVecS(:,  1) = (/ 1, -1,  0/)
    this%fSlipVecS(:,  2) = (/ 0, -1,  1/)
    this%fSlipVecS(:,  3) = (/-1,  0,  1/)
    this%fSlipVecS(:,  4) = (/ 1,  1,  0/)
    this%fSlipVecS(:,  5) = (/ 0,  1,  1/)
    this%fSlipVecS(:,  6) = (/-1,  0,  1/)
    this%fSlipVecS(:,  7) = (/ 1, -1,  0/)
    this%fSlipVecS(:,  8) = (/ 0,  1,  1/)
    this%fSlipVecS(:,  9) = (/ 1,  0,  1/)
    this%fSlipVecS(:, 10) = (/ 1,  1,  0/)
    this%fSlipVecS(:, 11) = (/ 0, -1,  1/)
    this%fSlipVecS(:, 12) = (/ 1,  0,  1/)

    this%fSlipVecM(:,  1) = (/ 1,  1,  1/)
    this%fSlipVecM(:,  2) = (/ 1,  1,  1/)
    this%fSlipVecM(:,  3) = (/ 1,  1,  1/)
    this%fSlipVecM(:,  4) = (/ 1, -1,  1/)
    this%fSlipVecM(:,  5) = (/ 1, -1,  1/)
    this%fSlipVecM(:,  6) = (/ 1, -1,  1/)
    this%fSlipVecM(:,  7) = (/-1, -1,  1/)
    this%fSlipVecM(:,  8) = (/-1, -1,  1/)
    this%fSlipVecM(:,  9) = (/-1, -1,  1/)
    this%fSlipVecM(:, 10) = (/-1,  1,  1/)
    this%fSlipVecM(:, 11) = (/-1,  1,  1/)
    this%fSlipVecM(:, 12) = (/-1,  1,  1/)

    this%fSlipSet    = 1

  end subroutine SetSlipVectors

end module typeSlipGeomFCC
 



module typeSlipGeomBCC
  use typeSlipGeom
  use utils, only : RKIND, IKIND


  !********Declaration of derived class BCCGeom
  type, extends(SlipGeom), public :: SlipGeomBCC
  contains
    procedure, private :: SetSlipVectors 
    final     :: Destructor
  end type SlipGeomBCC

  interface SlipGeomBCC
    module procedure Constructor
  end interface
  !******* End of declaration of class BCCGeom
contains


  function Constructor() result(this)
    type(SlipGeomBCC), pointer :: this
    integer(kind = IKIND), parameter :: kNumSlipSet = 1
    integer(kind = IKIND), parameter :: kNumSlipSys = 12

    allocate(this)

    this%fNumSlipSet = kNumSlipSet
    this%fNumSlipSys = kNumSlipSys

    call this%InitSlipGeom()

  end function Constructor

  subroutine Destructor(this)
    type(SlipGeomBCC) :: this

    call this%DestroySlipGeom()

  end subroutine Destructor

  subroutine SetSlipVectors(this)
    class(SlipGeomBCC) :: this


  end subroutine

end module typeSlipGeomBCC


module typeSlipGeomHCP
  use typeSlipGeom
  use utils, only : RKIND, IKIND

  !********Declaration of derived class SlipGeomHCP
  type, extends(SlipGeom), public :: SlipGeomHCP
  contains
    procedure, private :: SetSlipVectors 
    final     :: Destructor
  end type SlipGeomHCP

  interface SlipGeomHCP
    module procedure Constructor
  end interface
  !******* End of declaration of class BCCGeom
contains


  function Constructor() result(this)
    type(SlipGeomHCP), pointer :: this
    integer(kind = IKIND), parameter :: kNumSlipSet = 1
    integer(kind = IKIND), parameter :: kNumSlipSys = 12

    allocate(this)

    this%fNumSlipSet = kNumSlipSet
    this%fNumSlipSys = kNumSlipSys

    call this%InitSlipGeom()

  end function Constructor


  subroutine Destructor(this)
    type(SlipGeomHCP) :: this

    call this%DestroySlipGeom()

  end subroutine Destructor

  subroutine SetSlipVectors(this)
    class(SlipGeomHCP) :: this


  end subroutine

end module typeSlipGeomHCP



module typeSlipGeomUser
  use typeSlipGeom
  use utils


  type, extends(SlipGeom), public :: SlipGeomUser
    integer(kind = IKIND) :: fID  
  contains
    procedure, private :: SetSlipVectors
    final     :: Destructor
  end type SlipGeomUser

  interface SlipGeomUser
    module procedure Constructor
  end interface

contains
        

  function Constructor(fID) result(this)
    use utils, only : ReadLine
    type(SlipGeomUser), pointer :: this
    integer(kind = IKIND), intent(in) :: fID

    character(len = 256) :: line
    allocate(this)

    this%fID = fID
    call ReadLine(this%fID, line)
    read(line, *) this%fNumSlipSet, this%fNumSlipSys

    call this%InitSlipGeom()

  end function Constructor


  subroutine Destructor(this)
    type(SlipGeomUser) :: this

    call this%DestroySlipGeom()

  end subroutine Destructor


  subroutine SetSlipVectors(this)
    use utils, only : ReadLine
    class(SlipGeomUser) :: this

    character(len = 256) :: line
    integer :: i

    do i = 1, this%fNumSlipSys
      call ReadLine(this%fID, line)
      read(line, *) this%fSlipVecM(1:3, i), this%fSlipVecS(1:3, i), this%fSlipSet(i)
    end do
      
  end subroutine SetSlipVectors
  
end module typeSlipGeomUser


 
